// import Foundation
// import AirshipKit
//
// class PluginConfig {
//
//     private enum Keys : String {
//         case appKey
//         case appSecret
//     }
//
//     private static let defaults = UserDefaults(suiteName: "com.urbanairship.flutter")!
//
//     static var appKey: String? {
//         get { return read(.appKey) }
//         set { write(.appKey, value: newValue) }
//     }
//
//     static var appSecret: String? {
//         get { return read(.appSecret) }
//         set { write(.appSecret, value: newValue) }
//     }
//
//     private static func read<T>(_ key: Keys) -> T? {
//         return defaults.object(forKey: key.rawValue) as? T
//     }
//
//     private static func write(_ key: Keys, value: Any?) {
//         defaults.set(value, forKey: key.rawValue)
//     }
// }
// /* Copyright Airship and Contributors */

import Foundation
import AirshipCore

extension Config {
    static func parse(_ configDict: [String : Any]) throws -> Config {
    //  private static let defaults = UserDefaults(suiteName: "com.urbanairship.flutter")!
        let airshipConfig = Config.default()

        let defaultEnvironment = try Environment.fromConfig(configDict["default"])
        let prodEnvironment = try Environment.fromConfig(configDict["production"])
        let devEnvironment = try Environment.fromConfig(configDict["development"])

        if let appKey = defaultEnvironment?.appKey, let appSecret = defaultEnvironment?.appSecret {
            airshipConfig.defaultAppKey = appKey
            airshipConfig.defaultAppSecret = appSecret
        }

        if let appKey = prodEnvironment?.appKey, let appSecret = prodEnvironment?.appSecret {
            airshipConfig.productionAppKey = appKey
            airshipConfig.productionAppSecret = appSecret
        }

        if let appKey = devEnvironment?.appKey, let appSecret = devEnvironment?.appSecret {
            airshipConfig.developmentAppKey = appKey
            airshipConfig.developmentAppSecret = appSecret
        }

        if let logLevel = (prodEnvironment?.logLevel ?? defaultEnvironment?.logLevel) {
            airshipConfig.productionLogLevel = logLevel;
        }

        if let logLevel = (devEnvironment?.logLevel ?? defaultEnvironment?.logLevel) {
            airshipConfig.developmentLogLevel = logLevel;
        }

        if configDict["inProduction"] != nil {
            airshipConfig.inProduction = configDict["inProduction"] as? Bool ?? false
        }

        if let iOSConfig = configDict["iOS"] as? [String : Any] {
            airshipConfig.itunesID = iOSConfig["itunesId"] as? String
        }

        if let siteString = configDict["site"] as? String {
            airshipConfig.site = try CloudSite.parse(name: siteString)
        }

        if let features = configDict["enabledFeatures"] as? [String] {
            airshipConfig.enabledFeatures = try Features.parse(features)
        }

        if let allowList = configDict["urlAllowList"] as? [String] {
            airshipConfig.urlAllowList = allowList
        }

        if let allowList = configDict["urlAllowListScopeOpenUrl"] as? [String] {
            airshipConfig.urlAllowListScopeOpenURL = allowList
        }

        if let allowList = configDict["urlAllowListScopeJavaScriptInterface"] as? [String] {
            airshipConfig.urlAllowListScopeJavaScriptInterface = allowList
        }

        return airshipConfig
    }
}


private struct Environment {
    let logLevel: LogLevel?
    let appKey: String?
    let appSecret: String?

    static func fromConfig(_ config: Any?) throws -> Environment? {
        guard let config = config as? [String : String] else {
            return nil
        }

        var logLevel: LogLevel?
        if let logLevelString = config["logLevel"] {
            logLevel = try LogLevel.parse(name: logLevelString)
        }

        return Environment(logLevel: logLevel,
                           appKey: config["appKey"],
                           appSecret: config["appSecret"])

    }
}
