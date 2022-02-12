import Foundation
import AirshipKit

class PluginConfig {
    
    private enum Keys : String {
        case appKey
        case appSecret
    }
    
    private static let defaults = UserDefaults(suiteName: "com.urbanairship.flutter")!
    
    static var appKey: String? {
        get { return read(.appKey) }
        set { write(.appKey, value: newValue) }
    }
    
    static var appSecret: String? {
        get { return read(.appSecret) }
        set { write(.appSecret, value: newValue) }
    }
    
    private static func read<T>(_ key: Keys) -> T? {
        return defaults.object(forKey: key.rawValue) as? T
    }
    
    private static func write(_ key: Keys, value: Any?) {
        defaults.set(value, forKey: key.rawValue)
    }
}
