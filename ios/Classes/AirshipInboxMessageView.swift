import Foundation
import AirshipKit

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

class AirshipInboxMessageView : NSObject, FlutterPlatformView, NativeBridgeDelegate, WKNavigationDelegate, UANavigationDelegate {
    let webView : WKWebView
    let nativeBridge = NativeBridge()
    let channel : FlutterMethodChannel
    var webviewResult : FlutterResult
    
    init(frame: CGRect, viewId: Int64, registrar: FlutterPluginRegistrar) {
        self.webView = WKWebView(frame: frame)
        self.webView.allowsLinkPreview = !MessageCenter.shared.defaultUI.disableMessageLinkPreviewAndCallouts
        self.webView.configuration.dataDetectorTypes = [.all]
        
        let channelName = "com.airship.flutter/InboxMessageView_\(viewId)"
        self.channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
        self.webviewResult = { result in print(result!) }
        
        super.init()
        
        self.webView.navigationDelegate = self.nativeBridge
        self.nativeBridge.forwardNavigationDelegate = self
        self.nativeBridge.nativeBridgeDelegate = self
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
        webviewResult = result
        channel.invokeMethod("onLoadStarted", arguments: nil)
        guard let messageId = call.arguments as? String else {
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
        
        if let message = MessageCenter.shared.messageList.message(forID: messageId) {
            var request = URLRequest(url: message.messageBodyURL)
            let user = MessageCenter.shared.user
            
            user.getData({ (userData) in
                guard let auth = Utils.authHeader(username: userData.username, password: userData.password) else {
                    result(FlutterError(code:"InvalidState",
                                        message:"User not created.",
                                        details:nil))
                    return
                }
                request.addValue(auth, forHTTPHeaderField: "Authorization")
                DispatchQueue.main.async {
                    self.webView.load(request)
                    message.markRead(completionHandler: nil)
                }
                
            })
        } else {
            result(FlutterError(code:"InvalidMessage",
                                message:"Unable to load message: \(messageId)",
                                details:nil))
        }
    }
    
    func view() -> UIView {
        return webView
    }
    
    func close() {
        channel.invokeMethod("onClose", arguments: nil)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse,
                 decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
        if let response = navigationResponse.response as? HTTPURLResponse {
            if (response.statusCode >= 400 && response.statusCode <= 599) {
                decisionHandler(.cancel)
                if (response.statusCode == 410) {
                    webviewResult(FlutterError(code:"MessageLoadFailed",
                                               message:"Unable to load message",
                                               details:"Message not available"))
                } else {
                    webviewResult(FlutterError(code:"MessageLoadFailed",
                                               message:"Unable to load message",
                                               details:"Message load failed"))
                }
            }
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        channel.invokeMethod("onLoadFinished", arguments: nil)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        webviewResult(FlutterError(code:"MessageLoadFailed",
                                   message:"Unable to load message",
                                   details:error.localizedDescription))
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        webView.navigationDelegate?.webView?(webView, didFail: navigation, withError: error)
    }
}
