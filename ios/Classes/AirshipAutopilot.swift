import Flutter
import AirshipKit
import AirshipFrameworkProxy


@objc(FlutterAirshipAutopilot)
public class AirshipAutopilot: NSObject {
    
    @objc
    public static let shared: AirshipAutopilot = AirshipAutopilot()

    @objc
    public func onLoad(launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        self.launchOptions = launchOptions
        try? AirshipProxy.shared.attemptTakeOff(launchOptions: launchOptions)
    }
    
    private (set) var launchOptions: [UIApplication.LaunchOptionsKey : Any]?
}

extension AirshipAutopilot: AirshipProxyDelegate {
    public func migrateData(store: AirshipFrameworkProxy.ProxyStore) {
        guard
            let defaults = UserDefaults(suiteName: "com.urbanairship.flutter"),
            let appKey = defaults.string(forKey: "appKey"),
            let appSecret = defaults.string(forKey: "appSecret")
        else {
            return
        }
        
        // TODO
        
        defaults.removeObject(forKey: "appKey")
        defaults.removeObject(forKey: "appSecret")
    }
    
    public func loadDefaultConfig() -> AirshipConfig {
        return AirshipConfig.default()
    }
    
    public func onAirshipReady() {
        Airship.analytics.registerSDKExtension(
            SDKExtension.flutter,
            version: AirshipPluginVersion.pluginVersion
        )
    }
}
