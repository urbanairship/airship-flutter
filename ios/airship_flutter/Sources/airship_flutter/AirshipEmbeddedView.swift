import Foundation
import SwiftUI
import Flutter

#if canImport(AirshipCore)
import AirshipCore
#else
import AirshipKit
#endif

class AirshipEmbeddedViewFactory: NSObject, FlutterPlatformViewFactory {
    let registrar: FlutterPluginRegistrar

    init(_ registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
    }

    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return AirshipEmbeddedViewWrapper(frame: frame, viewId: viewId, registrar: self.registrar, args: args)
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

class AirshipEmbeddedViewWrapper: UIView, FlutterPlatformView {
    private static let embeddedIdKey: String = "embeddedId"

    private static func windowHeight() -> CGFloat? {
        return try? AirshipUtils.mainWindow()?.screen.bounds.height
    }

    private static func parseSelection(_ dict: [String: Any]?) -> AirshipEmbeddedSelection {
        if dict?["type"] as? String == "instance_id",
           let instanceId = dict?["instanceId"] as? String,
           !instanceId.isEmpty {
            return .instance(instanceId)
        }
        return .priority
    }

    private let viewModel = FlutterAirshipEmbeddedView.ViewModel()
    private let viewController: UIViewController
    private let channel: FlutterMethodChannel

    private let selfSizing: Bool
    private var isAdded: Bool = false
    private var reportedHeight: CGFloat = -1

    required init(frame: CGRect, viewId: Int64, registrar: FlutterPluginRegistrar, args: Any?) {
        let channelName = "com.airship.flutter/EmbeddedView_\(viewId)"
        self.channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())

        let params = args as? [String: Any]
        let parentHeight = (params?["parentHeight"] as? NSNumber).map { CGFloat($0.doubleValue) }
        self.selfSizing = parentHeight == nil

        let hostingController = UIHostingController(
            rootView: FlutterAirshipEmbeddedView(viewModel: self.viewModel)
        )
        hostingController.view.backgroundColor = .clear
        self.viewController = hostingController

        super.init(frame: frame)

        self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(hostingController.view)
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        if let params {
            if let embeddedId = params[Self.embeddedIdKey] as? String {
                viewModel.embeddedID = embeddedId
            }
            viewModel.selection = Self.parseSelection(params["selection"] as? [String: Any])
        }
        viewModel.parentWidth = frame.size.width
        // Percent sized content has no parent height to resolve against, so use the window.
        viewModel.parentHeight = parentHeight ?? Self.windowHeight()

        if selfSizing {
            viewModel.onHeightChange = { [weak self] height in
                self?.reportContentHeight(height)
            }
        }

        channel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            self?.handle(call, result: result)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func view() -> UIView {
        return self
    }

    public override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !self.isAdded else { return }

        let parent = self.parentViewController()
        self.viewController.willMove(toParent: parent)
        parent.addChild(self.viewController)
        self.viewController.didMove(toParent: parent)
        self.viewController.view.isUserInteractionEnabled = true
        self.isAdded = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if self.viewModel.parentWidth != bounds.size.width {
            self.viewModel.parentWidth = bounds.size.width
        }
    }

    private func reportContentHeight(_ height: CGFloat) {
        guard height >= 0, abs(height - self.reportedHeight) > 0.5 else { return }
        self.reportedHeight = height
        self.channel.invokeMethod("onSizeUpdate", arguments: ["height": height])
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(FlutterError(code: "UNAVAILABLE",
                            message: "Unknown method: \(call.method)",
                            details: nil))
    }
}

struct FlutterAirshipEmbeddedView: View {
    @ObservedObject
    var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        if let embeddedID = viewModel.embeddedID {
            AirshipEmbeddedView(embeddedID: embeddedID,
                                embeddedSize: .init(
                                    parentWidth: viewModel.parentWidth,
                                    parentHeight: viewModel.parentHeight
                                ),
                                selection: viewModel.selection
            )
            // Report the content's laid-out height so Flutter can size to it.
            .background(
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: ContentHeightPreferenceKey.self,
                        value: proxy.size.height
                    )
                }
            )
            .onPreferenceChange(ContentHeightPreferenceKey.self) { [viewModel] height in
                // The action is @Sendable, so hop to the main actor for the view model.
                Task { @MainActor in
                    viewModel.onHeightChange?(height)
                }
            }
        } else {
            Text("Please set embeddedId")
        }
    }

    @MainActor
    class ViewModel: ObservableObject {
        @Published var embeddedID: String?
        @Published var parentWidth: CGFloat?
        @Published var parentHeight: CGFloat?
        @Published var selection: AirshipEmbeddedSelection = .priority

        var onHeightChange: ((CGFloat) -> Void)?
    }
}

private struct ContentHeightPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

extension UIView {
    //Get Parent View Controller from any view
    func parentViewController() -> UIViewController {
        var responder: UIResponder? = self
        while !(responder is UIViewController) {
            responder = responder?.next
            if nil == responder {
                break
            }
        }
        return (responder as? UIViewController)!
    }
}
