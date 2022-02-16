import Flutter
import AirshipKit

@objc(FlutterAirshipAutopilot)
public class AirshipAutopilot: NSObject {
    
    @objc
    public static var launchOptions: [UIApplication.LaunchOptionsKey : Any]?

    @objc
    public static func attemptTakeOff() {
        if (Airship.isFlying) {
            return
        }
        
        let config = Config.default()
        config.developmentAppKey = config.developmentAppKey ?? PluginConfig.appKey
        config.developmentAppSecret = config.developmentAppSecret ?? PluginConfig.appSecret

        config.productionAppKey = config.productionAppKey ?? PluginConfig.appKey
        config.productionAppSecret = config.productionAppSecret ?? PluginConfig.appSecret
        
        guard config.validate() else {
            return
        }
        
        Airship.takeOff(config, launchOptions: self.launchOptions)
        Airship.analytics.registerSDKExtension(SDKExtension.flutter, version: AirshipPluginVersion.pluginVersion)
        Airship.push.defaultPresentationOptions = [.alert]
        AirshipAutopilot.loadCustomNotificationCategories()
        SwiftAirshipPlugin.shared.onAirshipReady()
    }

    private static func loadCustomNotificationCategories() {
        guard let categoriesPath = Bundle.main.path(forResource: "UACustomNotificationCategories", ofType: "plist") else { return }
        let customNotificationCategories = NotificationCategories.createCategories(fromFile: categoriesPath)

        if customNotificationCategories.count != 0 {
            Airship.push.customCategories = customNotificationCategories
            Airship.push.updateRegistration()
        }
    }
}
