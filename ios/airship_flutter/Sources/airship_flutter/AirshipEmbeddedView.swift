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

    private var selfSizing: Bool
    private var isAdded: Bool = false
    private var reportedHeight: CGFloat = -1

    required init(frame: CGRect, viewId: Int64, registrar: FlutterPluginRegistrar, args: Any?) {
        let channelName = "com.airship.flutter/EmbeddedView_\(viewId)"
        self.channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())

        let params = args as? [String: Any]
        let selfSizing = (params?["sizeToContent"] as? Bool) ?? false
        self.selfSizing = selfSizing

        let hostingController = UIHostingController(
            rootView: FlutterAirshipEmbeddedView(viewModel: self.viewModel)
        )
        hostingController.view.backgroundColor = .clear
        self.viewController = hostingController

        super.init(frame: frame)

        self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(hostingController.view)
        // The host is framed in layoutSubviews: while self sizing it is deliberately
        // taller than this view, so content measures against a stable proposal
        // instead of the box Flutter set, which would feed back into measurement.
        hostingController.view.autoresizingMask = []
        self.clipsToBounds = true

        if let params {
            if let embeddedId = params[Self.embeddedIdKey] as? String {
                viewModel.embeddedID = embeddedId
            }
            viewModel.selection = Self.parseSelection(params["selection"] as? [String: Any])
        }
        viewModel.parentWidth = frame.size.width
        viewModel.selfSizing = selfSizing
        // While self sizing there is no imposed height for percent sized content to
        // resolve against, so fall back to the window.
        viewModel.parentHeight = selfSizing ? Self.windowHeight() : frame.size.height

        viewModel.onHeightChange = { [weak self] height in
            self?.reportContentHeight(height)
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

        // Stable measurement proposal: window height while self sizing, so the
        // measured height cannot depend on the box Flutter just set.
        let hostHeight = self.selfSizing
            ? max(Self.windowHeight() ?? bounds.size.height, bounds.size.height)
            : bounds.size.height
        let hostFrame = CGRect(x: 0, y: 0, width: bounds.size.width, height: hostHeight)
        if self.viewController.view.frame != hostFrame {
            self.viewController.view.frame = hostFrame
        }

        if self.viewModel.parentWidth != bounds.size.width {
            self.viewModel.parentWidth = bounds.size.width
        }
        if !self.selfSizing, self.viewModel.parentHeight != bounds.size.height {
            self.viewModel.parentHeight = bounds.size.height
        }
    }

    private func reportContentHeight(_ height: CGFloat) {
        guard height >= 0, abs(height - self.reportedHeight) > 0.5 else { return }
        self.reportedHeight = height
        self.channel.invokeMethod("onSizeUpdate", arguments: ["height": height])
    }

    private func setSelfSizing(_ value: Bool) {
        guard self.selfSizing != value else { return }
        self.selfSizing = value
        // The next report is against a different measurement, so don't suppress it.
        self.reportedHeight = -1
        self.viewModel.selfSizing = value
        self.viewModel.parentHeight = value ? Self.windowHeight() : bounds.size.height
        self.setNeedsLayout()
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "setSizeToContent":
            let args = call.arguments as? [String: Any]
            setSelfSizing((args?["sizeToContent"] as? Bool) ?? false)
            result(nil)
        default:
            result(FlutterError(code: "UNAVAILABLE",
                                message: "Unknown method: \(call.method)",
                                details: nil))
        }
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
            // Report the height every layout pass, like the SDK's airshipMeasureView;
            // preference diffing missed the placeholder-to-content transition.
            // The wrapper dedupes before touching the channel.
            .background(
                GeometryReader { [viewModel] proxy -> Color in
                    let height = proxy.size.height
                    DispatchQueue.main.async {
                        viewModel.onHeightChange?(height)
                    }
                    return Color.clear
                }
            )
            // While self sizing the host is taller than the visible box, so pin the
            // content to the top rather than letting SwiftUI center it out of view.
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: viewModel.selfSizing ? .top : .center
            )
        } else {
            Text("Please set embeddedId")
        }
    }

    @MainActor
    class ViewModel: ObservableObject {
        @Published var embeddedID: String?
        @Published var parentWidth: CGFloat?
        @Published var parentHeight: CGFloat?
        @Published var selfSizing: Bool = false
        @Published var selection: AirshipEmbeddedSelection = .priority

        var onHeightChange: ((CGFloat) -> Void)?
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
