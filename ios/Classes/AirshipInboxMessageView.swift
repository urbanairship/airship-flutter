import AirshipKit
import Foundation

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

class AirshipInboxMessageView : NSObject, FlutterPlatformView {

    let webView : WKWebView
    let nativeBridge = UAWKWebViewNativeBridge()
    let channel : FlutterMethodChannel

    init(frame: CGRect, viewId: Int64, registrar: FlutterPluginRegistrar) {
        self.webView = WKWebView(frame: frame)
        self.webView.navigationDelegate = self.nativeBridge
        self.webView.allowsLinkPreview = !UAirship.messageCenter().disableMessageLinkPreviewAndCallouts
        self.webView.configuration.dataDetectorTypes = [.all]

        let channelName = "com.airship.flutter/InboxMessageView_\(viewId)"
        self.channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())

        super.init()

        weak var weakSelf = self
        channel.setMethodCallHandler { (call, result) in
            if let strongSelf = weakSelf {
                strongSelf.handle(call, result: result)
            } else {
                result(FlutterError(code:"UNAVAILABLE",
                                    message:"Instance no longer available",
                                    details:nil))
            }
        }
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
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
        let messageId = call.arguments as! String
        if let message = UAirship.inbox()?.messageList.message(forID: messageId) {
            var request = URLRequest(url: message.messageBodyURL)
            guard let userData = UAirship.inboxUser().getDataSync() else {
                result(FlutterError(code:"InvalidState",
                                    message:"User not created.",
                                    details:nil))
                return
            }
            let auth = UAUtils.userAuthHeaderString(userData)
            request.addValue(auth, forHTTPHeaderField: "Authorization")
            webView.load(request)
            message.markRead(completionHandler: nil)
            result(nil)
        } else {
            result(FlutterError(code:"InvalidMessage",
                                message:"Unable to load message: \(messageId)",
                details:nil))
        }
    }

    func view() -> UIView {
        return webView
    }
}
