import Foundation
import SwiftUI
import Flutter

#if canImport(AirshipCore)
import AirshipCore
import AirshipMessageCenter
#else
import AirshipKit
#endif

class AirshipInboxMessageViewFactory : NSObject, FlutterPlatformViewFactory {

    let registrar : FlutterPluginRegistrar

    init(_ registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
    }

    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return AirshipInboxMessageView(frame: frame, viewId: viewId, registrar: self.registrar)
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

@MainActor
private class MessageState: ObservableObject {
    @Published var viewModel: MessageCenterMessageViewModel?
    @Published var phase: MessageCenterMessageContentPhase = .loading
    var onClose: (@MainActor @Sendable () -> Void)?
    var onPhaseChange: (@MainActor (MessageCenterMessageContentPhase) -> Void)?
}

private struct MessageContainerView: View {
    @ObservedObject var state: MessageState

    var body: some View {
        if let viewModel = state.viewModel {
            MessageCenterMessageContentView(
                viewModel: viewModel,
                phase: $state.phase,
                dismissAction: state.onClose
            )
            .id(viewModel.messageID)
            .onChange(of: state.phase) { phase in
                state.onPhaseChange?(phase)
            }
        }
    }
}

class AirshipInboxMessageView : UIView, FlutterPlatformView {
    private let state = MessageState()
    private let viewController: UIViewController
    private var isAdded = false
    private let channel: FlutterMethodChannel
    private var webviewResult: FlutterResult? = nil

    required init(frame: CGRect, viewId: Int64, registrar: FlutterPluginRegistrar) {
        let channelName = "com.airship.flutter/InboxMessageView_\(viewId)"
        self.channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
        self.viewController = UIHostingController(rootView: MessageContainerView(state: self.state))
        self.viewController.view.backgroundColor = .clear

        super.init(frame: frame)

        self.addSubview(self.viewController.view)
        self.viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        self.state.onClose = { [weak self] in
            self?.channel.invokeMethod("onClose", arguments: nil)
        }

        self.state.onPhaseChange = { [weak self] phase in
            guard let self else { return }
            switch phase {
            case .loading:
                break
            case .loaded:
                self.channel.invokeMethod("onLoadFinished", arguments: nil)
                Task { await self.state.viewModel?.markRead() }
            case .error(let error):
                let details = error == .messageGone ? "Message not available" : "Message load failed"
                self.webviewResult?(FlutterError(
                    code: "MessageLoadFailed",
                    message: "Unable to load message",
                    details: details
                ))
                self.webviewResult = nil
            }
        }

        weak var weakSelf = self
        channel.setMethodCallHandler { (call, result) in
            guard let strongSelf = weakSelf else {
                result(FlutterError(code:"UNAVAILABLE",
                                    message:"Instance no longer available",
                                    details:nil))
                return
            }
            strongSelf.handle(call, result: result)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "loadMessage":
            loadMessage(call, result: result)
        default:
            result(FlutterError(code:"UNAVAILABLE",
                                message:"Unknown method: \(call.method)",
                                details:nil))
        }
    }

    private func loadMessage(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let messageID = call.arguments as? String else {
            result(FlutterError(code: "InvalidArgument",
                                message: "Must be a message ID",
                                details:nil))
            return
        }

        guard Airship.isFlying else {
            result(FlutterError(code: "AIRSHIP_GROUNDED",
                                message: "Takeoff not called.",
                                details: nil))
            return
        }

        webviewResult = result
        channel.invokeMethod("onLoadStarted", arguments: nil)

        state.phase = .loading
        state.viewModel = MessageCenterMessageViewModel(messageID: messageID)
    }

    func view() -> UIView {
        return self
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isAdded else { return }
        viewController.willMove(toParent: parentViewController())
        parentViewController().addChild(viewController)
        viewController.didMove(toParent: parentViewController())
        viewController.view.isUserInteractionEnabled = true
        isAdded = true
    }
}
