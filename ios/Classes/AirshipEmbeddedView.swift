import Foundation
import AirshipKit
import SwiftUI

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

    var viewModel = FlutterAirshipEmbeddedView.ViewModel()

    public var viewController: UIViewController
    
    public var isAdded: Bool = false

    let channel: FlutterMethodChannel

    required init(frame: CGRect, viewId: Int64, registrar: FlutterPluginRegistrar, args: Any?) {
        let channelName = "com.airship.flutter/EmbeddedView_\(viewId)"
        self.channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())

        self.viewController = UIHostingController(
            rootView: FlutterAirshipEmbeddedView(viewModel: self.viewModel)
        )

        self.viewController.view.backgroundColor = UIColor.purple

        let rootView = FlutterAirshipEmbeddedView(viewModel: self.viewModel)
        self.viewController = UIHostingController(
            rootView: rootView
        )

        super.init(frame:frame)

        self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.viewController.view)
        self.viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        if let params = args as? [String: Any], let embeddedId = params[Self.embeddedIdKey] as? String {
            rootView.viewModel.embeddedID = embeddedId
        }

        rootView.viewModel.size = frame.size

        channel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            self?.handle(call, result: result)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getSize":
            let width = self.bounds.width
            let height = self.bounds.height
            result(["width": width, "height": height])
        case "getIsAdded":
            result(["isAdded": self.isAdded])
        default:
            result(FlutterError(code: "UNAVAILABLE",
                                message: "Unknown method: \(call.method)",
                                details: nil))
        }
    }

    func view() -> UIView {
        return self
    }

    public override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !self.isAdded else { return }
        self.viewController.willMove(toParent: self.parentViewController())
        self.parentViewController().addChild(self.viewController)
        self.viewController.didMove(toParent: self.parentViewController())
        self.viewController.view.isUserInteractionEnabled = true
        isAdded = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.viewModel.size = bounds.size
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
                                    parentWidth: viewModel.size?.width,
                                    parentHeight: viewModel.size?.height
                                )
            ) {
                Text("Placeholder: \(embeddedID) \(viewModel.size ?? CGSize())")
            }
        } else {
            Text("Please set embeddedId")
        }
    }

    @MainActor
    class ViewModel: ObservableObject {
        @Published var embeddedID: String?
        @Published var size: CGSize?

        var height: CGFloat {
            guard let height = self.size?.height, height > 0 else {
                return try! AirshipUtils.mainWindow()?.screen.bounds.height ?? 500
            }
            return height
        }

        var width: CGFloat {
            guard let width = self.size?.width, width > 0 else {
                return try! AirshipUtils.mainWindow()?.screen.bounds.width ?? 500
            }
            return width
        }
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
