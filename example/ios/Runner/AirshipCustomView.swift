import Flutter
import UIKit
import SwiftUI
import AirshipFrameworkProxy

#if canImport(AirshipCore)
import AirshipCore
import AirshipAutomation
#else
import AirshipKit
#endif

/// SwiftUI wrapper for Flutter custom view
@available(iOS 16.0, *)
public struct FlutterCustomViewWrapper: View {
    let viewName: String
    let properties: AirshipJSON?

    public var body: some View {
        FlutterCustomViewRepresentable(viewName: viewName, properties: properties)
    }
}

/// UIViewRepresentable bridge for SwiftUI
@available(iOS 16.0, *)
struct FlutterCustomViewRepresentable: UIViewRepresentable {
    let viewName: String
    let properties: AirshipJSON?

    func makeUIView(context: Context) -> FlutterCustomView {
        return FlutterCustomView(viewName: viewName, properties: properties)
    }

    func updateUIView(_ uiView: FlutterCustomView, context: Context) {
        // No updates needed
    }
}

/// Flutter custom view that embeds a Flutter widget
public class FlutterCustomView: UIView {
    private let viewName: String
    private let properties: AirshipJSON?
    private var flutterEngine: FlutterEngine?
    private var flutterViewController: FlutterViewController?

    public init(viewName: String, properties: AirshipJSON?) {
        self.viewName = viewName
        self.properties = properties
        super.init(frame: .zero)
        setupView()
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        // View will fill whatever size Airship gives us
        backgroundColor = .systemGray6
        clipsToBounds = true
    }

    override public func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)

        if newWindow != nil {
            embedFlutterView()
        } else {
            removeFlutterView()
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        // Flutter view exactly fills our bounds
        flutterViewController?.view.frame = bounds
    }

    private func embedFlutterView() {
        // Encode properties as base64 to pass in route
        var route = "/custom/\(viewName)"
        if let props = properties {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: props.unWrap() ?? [:])
                let encodedProperties = jsonData.base64EncodedString(options: [])
                    .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                route = "/custom/\(viewName)?props=\(encodedProperties)"
            } catch {}
        }

        // Create a new Flutter engine
        flutterEngine = FlutterEngine(name: "airship_custom_\(viewName)")

        // Run the engine with initial route
        let result = flutterEngine?.run(withEntrypoint: nil, initialRoute: route)

        guard result == true else {
            return
        }

        // Create Flutter view controller
        flutterViewController = FlutterViewController(
            engine: flutterEngine!,
            nibName: nil,
            bundle: nil
        )

        guard let flutterViewController = flutterViewController else {
            return
        }

        // Add the Flutter view
        addSubview(flutterViewController.view)
    }

    private func removeFlutterView() {
        flutterViewController?.view.removeFromSuperview()
        flutterViewController = nil

        flutterEngine?.destroyContext()
        flutterEngine = nil
    }
}
