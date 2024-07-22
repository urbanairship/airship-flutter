import Foundation
import AirshipKit
import SwiftUI

class AirshipEmbeddedViewFactory : NSObject, FlutterPlatformViewFactory {
    let registrar : FlutterPluginRegistrar

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

/// The Flutter wrapper for the Airship embedded view
class AirshipEmbeddedViewWrapper : NSObject, FlutterPlatformView {
    private static let embeddedIdKey: String = "embeddedId"

    @ObservedObject
    var viewModel = FlutterAirshipEmbeddedView.ViewModel()

    public var viewController: UIViewController?

    let channel : FlutterMethodChannel
    private var _view: UIView

    init(frame: CGRect, viewId: Int64, registrar: FlutterPluginRegistrar, args: Any?) {
        let channelName = "com.airship.flutter/EmbeddedView_\(viewId)"
        self.channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
        _view = UIView(frame: frame)

        super.init()

        let rootView = FlutterAirshipEmbeddedView(viewModel: viewModel)
        self.viewController = UIHostingController(
            rootView: rootView
        )

        _view.translatesAutoresizingMaskIntoConstraints = false
        _view.addSubview(self.viewController!.view)
        self.viewController?.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        Task { @MainActor in
            if let params = args as? [String: Any], let embeddedId = params[Self.embeddedIdKey] as? String {
                rootView.viewModel.embeddedID = embeddedId
            }

            rootView.viewModel.size = frame.size
        }
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) async {
        switch call.method {
        default:
            result(FlutterError(code:"UNAVAILABLE",
                                message:"Unknown method: \(call.method)",
                                details:nil))
        }
    }

    func view() -> UIView {
        return _view
    }
}

struct FlutterAirshipEmbeddedView: View {
    @ObservedObject
    var viewModel:ViewModel

    var body: some View {
        if let embeddedID = viewModel.embeddedID {
            AirshipEmbeddedView(embeddedID: embeddedID,
                                embeddedSize: .init(
                                    parentWidth: viewModel.width,
                                    parentHeight: viewModel.height
                                )
            ) {
                Text("Placeholder: \(embeddedID) \(viewModel.size ?? CGSize())")
            }
        } else {
            Text("Please set embeddedId")
        }
        Text("Size: \(viewModel.width)x\(viewModel.height) pts")
    }

    @MainActor
    class ViewModel: ObservableObject {
        @Published var embeddedID: String?
        @Published var size: CGSize?

        var height: CGFloat {
            guard let height = self.size?.height, height > 0 else {
                return try! AirshipUtils.mainWindow()?.screen.bounds.height ?? 420
            }
            return height
        }

        var width: CGFloat {
            guard let width = self.size?.width, width > 0 else {
                return try! AirshipUtils.mainWindow()?.screen.bounds.width ?? 420
            }
            return width
        }
    }
}
