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
        
        guard let configDict = PluginStore.protoConfig else {
            return
        }
        do {
            
            let config = try Config.parse(configDict)
            Airship.takeOff(config, launchOptions: self.launchOptions)
        } catch {
            AirshipLogger.error("Failed to takeOff \(error)")
        }
        
        
        SwiftAirshipPlugin.defaults.set(true, forKey: SwiftAirshipPlugin.shared.autoLaunchPreferenceCenterKey)
        
        
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
