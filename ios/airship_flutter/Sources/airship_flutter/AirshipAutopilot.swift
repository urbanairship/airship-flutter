import Flutter
import AirshipFrameworkProxy

#if canImport(AirshipCore)
import AirshipCore
#else
import AirshipKit
#endif

public class AirshipAutopilot: NSObject {
    
    @objc
    public static let shared: AirshipAutopilot = AirshipAutopilot()

    @MainActor @objc
    public func onLoad(launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        self.launchOptions = launchOptions
        /// Set Airship Proxy Delegate on Airship Autopilot
        AirshipProxy.shared.delegate = self

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
        
        store.config = ProxyConfig(
            defaultEnvironment: ProxyConfig.Environment(
                logLevel: nil,
                appKey: appKey,
                appSecret: appSecret, 
                ios: nil
            )
        )

        defaults.removeObject(forKey: "appKey")
        defaults.removeObject(forKey: "appSecret")
    }
    
    public func loadDefaultConfig() -> AirshipConfig {

        let path = Bundle.main.path(
            forResource: "AirshipConfig",
            ofType: "plist"
        )

        var config: AirshipConfig?
        if let path = path, FileManager.default.fileExists(atPath: path) {
            do {
                config = try AirshipConfig.default()
            } catch {
                AirshipLogger.error("Failed to load AirshipConfig.plist: \(error)")
            }
        }

        return config ?? AirshipConfig()
    }
    
    public func onAirshipReady() {
        Airship.analytics.registerSDKExtension(
            AirshipSDKExtension.flutter,
            version: AirshipPluginVersion.pluginVersion
        )
    }
}

