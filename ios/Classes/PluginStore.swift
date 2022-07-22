/* Copyright Airship and Contributors */

import Foundation
import AirshipKit

class PluginStore {
    
    private static let defaults = SwiftAirshipPlugin.defaults
    
    public static var config: [String: Any]? {
        get {
            return self.read("config")
        }
        set {
            self.write("config", value: newValue)
        }
    }
    
    public static var protoConfig:  AirshipConfig? {
        get {
            do{
                let data = defaults.value(forKey: "protoConfig")
                guard data != nil else {
                    return nil
                }
                return try AirshipConfig.init(serializedData: data as! Data);
            } catch  {
                fatalError("Invalid config: \(String(describing: error))")
            }
        }
        set  {
            do {
                try defaults.set(newValue?.serializedData(), forKey: "protoConfig")
            }catch{
                fatalError("Invalid config: \(String(describing: newValue))")
            }
        }
    }
    
    public static var presentationOptions: UNNotificationPresentationOptions {
        get {
            return self.read("presentationOptions") ?? []
        }
        set {
            self.write("presentationOptions", value: newValue)
        }
    }
    
    public static func getUseCustomPreferenceCenter(_ preferenceCenterID: String) -> Bool {
        return self.read("useCustomPreferenceCenter-\(preferenceCenterID)") ?? false
    }
    
    public static func setUseCustomPreferenceCenter(_ preferenceCenterID: String, enabled: Bool) {
        self.write("useCustomPreferenceCenter-\(preferenceCenterID)", value: enabled)
    }
    
    private static func write(_ key: String, value: Any?) -> Void {
        if let value = value {
            defaults.set(value, forKey: key)
        } else {
            defaults.removeObject(forKey: key)
        }
    }
    
    private static func read<T>(_ key: String) -> T? {
        return defaults.value(forKey: key) as? T
    }
}
