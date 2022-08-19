/* Copyright Airship and Contributors */
import Foundation
import AirshipKit

class PluginConfig {
    
    private enum Keys: String {
        case appKey
        case appSecret
    }
    
    private static let defaults = UserDefaults(suiteName: "com.urbanairship.flutter")!
    
    static var appKey: String? {
        get {
            return read(.appKey)
        }
        set {
            write(.appKey, value: newValue)
        }
    }
    
    static var appSecret: String? {
        get {
            return read(.appSecret)
        }
        set {
            write(.appSecret, value: newValue)
        }
    }
    
    private static func read<T>(_ key: Keys) -> T? {
        return defaults.object(forKey: key.rawValue) as? T
    }
    
    private static func write(_ key: Keys, value: Any?) {
        if let value = value {
            defaults.set(value, forKey: key.rawValue)
        } else {
            defaults.removeObject(forKey: key.rawValue)
        }
    }
}



extension Config {
    static func parse(_ configDict: AirshipConfig) throws -> Config {
        let airshipConfig = Config.default()
        
        airshipConfig.parseDefaultEnv(configDict.defaultEnv)
        airshipConfig.parseProductionEnv(configDict.production)
        airshipConfig.parseDevelopmentEnv(configDict.development)
        
        
        airshipConfig.inProduction = configDict.inProduction
        
        airshipConfig.itunesID = configDict.ios.itunesID
        
        airshipConfig.site =  configDict.site.toSite()
        
        airshipConfig.enabledFeatures =  configDict.featuresEnabled.value()
        
        
        
        airshipConfig.urlAllowList = configDict.urlAllowList
        
        
        airshipConfig.urlAllowListScopeOpenURL = configDict.urlAllowListScopeOpenURL
        
        
        airshipConfig.urlAllowListScopeJavaScriptInterface = configDict.urlAllowlistScopeJavascriptInterface
        
        
        return airshipConfig
    }
    
    private func parseDefaultEnv(_ defaultEnv: AirshipEnv){
        if(!defaultEnv.isEmptyOrPatial){
            defaultAppKey = defaultEnv.appKey
            defaultAppSecret = defaultEnv.appSecret
            productionLogLevel = defaultEnv.logLevel.value()
        }
    }
    
    private func parseDevelopmentEnv(_ developmentEnv: AirshipEnv){
        if(!developmentEnv.isEmptyOrPatial){
            developmentAppKey = developmentEnv.appKey
            developmentAppSecret = developmentEnv.appSecret
            developmentLogLevel = developmentEnv.logLevel.value()
        }
    }
    
    private func parseProductionEnv(_ productionEnv: AirshipEnv){
        if(!productionEnv.isEmptyOrPatial){
            productionAppKey = productionEnv.appKey
            productionAppSecret = productionEnv.appSecret
            productionLogLevel = productionEnv.logLevel.value()
        }
    }
    
}

extension AirshipEnv{
    var isEmptyOrPatial: Bool {
        get{
            return appKey.isEmpty || appSecret.isEmpty
        }
        
    }
}

extension Site {
    func toSite() -> CloudSite {
        switch (self) {
        case .eu:
            return CloudSite.eu
        case .us:
            return CloudSite.us
        case .UNRECOGNIZED(_):
            return CloudSite.us
        }
    }
}


extension Array where Element == Feature {
    func value() -> Features {
        if(isEmpty){
            return Features.all
        }
        var features: Features = []
        forEach { feature in
            features.update(with: feature.value())
        }
        
        return features
    }
}

extension Feature{
    func value() -> Features {
        switch(self){
        case .enableAll:
            return Features.all
        case .enableNone:
            return []
        case .enableInAppAutomation:
            return Features.inAppAutomation
        case .enableMessageCenter:
            return Features.messageCenter
        case .enablePush:
            return Features.push
        case .enableChat:
            return Features.chat
        case .enableAnalytics:
            return Features.analytics
        case .enableTagsAndAttributes:
            return Features.tagsAndAttributes
        case .enableContacts:
            return Features.contacts
        case .enableLocation:
            return Features.location
        case .UNRECOGNIZED(_):
            return Features.all
        }
    }
}

extension airship_flutter.LogLevel {
    func value() -> AirshipKit.LogLevel{
        switch(self){
        case .none:
            return AirshipKit.LogLevel.none
        case .verbose:
            return AirshipKit.LogLevel.trace
        case .debug:
            return AirshipKit.LogLevel.debug
        case .info:
            return AirshipKit.LogLevel.info
        case .warn:
            return AirshipKit.LogLevel.warn
        case .error:
            return AirshipKit.LogLevel.error
        case .UNRECOGNIZED(_):
            return AirshipKit.LogLevel.undefined
        }
    }
}
