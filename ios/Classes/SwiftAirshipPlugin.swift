import Flutter
import UIKit
import AirshipKit

public class SwiftAirshipPlugin: NSObject, FlutterPlugin {
    
    private let eventNameKey = "event_name"
    private let eventValueKey = "event_value"
    private let propertiesKey = "properties"
    private let transactionIDKey = "transaction_id"
    private let interactionIDKey = "interaction_id"
    private let interactionTypeKey = "interaction_type"
    private let tagOperationGroupName = "group"
    private let tagOperationType = "operationType"
    private let tagOperationTags = "tags"
    private let tagOperationAdd = "add"
    private let tagOperationRemove = "remove"
    private let tagOperationSet = "set"

    private let attributeOperationType = "action"
    private let attributeOperationSet = "set"
    private let attributeOperationRemove = "remove"
    private let attributeOperationKey = "key"
    private let attributeOperationValue = "value"
    
    let autoLaunchPreferenceCenterKey = "auto_launch_pc"
    
    static let shared = SwiftAirshipPlugin()

    let eventHandler = AirshipEventHandler()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.airship.flutter/airship",
                                           binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(shared, channel: channel)
        AirshipEventManager.shared.register(registrar)

        registrar.register(AirshipInboxMessageViewFactory(registrar), withId: "com.airship.flutter/InboxMessageView")
    }
    
    public func onAirshipReady() {
        eventHandler.register()
    }
    
    // MARK: - handle methods call
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method == "takeOff") {
            takeOff(call, result: result)
            return
        }
        
        guard (Airship.isFlying) else {
            result(FlutterError(code:"AIRSHIP_GROUNDED",
                              message:"TakeOff not called.",
                               details: nil))
            return
        }
        
        switch call.method {
        case "getChannelId":
            getChannelId(call, result: result)
        case "setUserNotificationsEnabled":
            setUserNotificationsEnabled(call, result: result)
        case "getUserNotificationsEnabled":
            getUserNotificationsEnabled(call, result: result)
        case "clearNotification":
            clearNotification(call, result: result)
        case "clearNotifications":
            clearNotifications(call, result: result)
        case "getActiveNotifications":
            getActiveNotifications(call, result: result)
        case "addTags":
            addTags(call, result: result)
        case "addEvent":
            addEvent(call, result: result)
        case "removeTags":
            removeTags(call, result: result)
        case "getTags":
            getTags(call, result: result)
        case "editAttributes":
            editChannelAttributes(call, result: result)
        case "editChannelAttributes":
            editChannelAttributes(call, result: result)
        case "editNamedUserAttributes":
            editNamedUserAttributes(call, result: result)
        case "editNamedUserTagGroups":
            editNamedUserTagGroups(call, result: result)
        case "editChannelTagGroups":
            editChannelTagGroups(call, result: result)
        case "setNamedUser":
            setNamedUser(call, result: result)
        case "getNamedUser":
            getNamedUser(call, result: result)
        case "getInboxMessages":
            getInboxMessages(call, result: result)
        case "markInboxMessageRead":
            markInboxMessageRead(call, result: result)
        case "deleteInboxMessage":
            deleteInboxMessage(call, result: result)
        case "setInAppAutomationPaused":
            setInAppAutomationPaused(call, result: result)
        case "getInAppAutomationPaused":
            getInAppAutomationPaused(call, result: result)
        case "enableChannelCreation":
            enableChannelCreation(call, result: result)
        case "trackScreen":
            trackScreen(call, result: result)
        case "refreshInbox":
            refreshInbox(call, result: result)
        case "setBadge":
            setBadge(call, result: result)
        case "resetBadge":
            resetBadge(call, result: result)
        case "setAutoBadgeEnabled":
            setAutoBadgeEnabled(call, result: result)
        case "isAutoBadgeEnabled":
            isAutoBadgeEnabled(call, result: result)
        case "enableFeatures":
            enableFeatures(call, result: result)
        case "disableFeatures":
            disableFeatures(call, result: result)
        case "setEnabledFeatures":
            setEnabledFeatures(call, result: result)
        case "getEnabledFeatures":
            getEnabledFeatures(call, result: result)
        case "isFeatureEnabled":
            isFeatureEnabled(call, result: result)
        case "openPreferenceCenter":
            openPreferenceCenter(call, result: result)
        case "getSubscriptionLists":
            getSubscriptionLists(call, result: result)
        case "editChannelSubscriptionLists":
            editChannelSubscriptionLists(call, result: result)
        case "editContactSubscriptionLists":
            editContactSubscriptionLists(call, result: result)
        case "getPreferenceCenterConfig":
            getPreferenceCenterConfig(call, result: result)
        case "setAutoLaunchDefaultPreferenceCenter":
            setAutoLaunchDefaultPreferenceCenter(call, result: result)
        default:
            result(FlutterError(code:"UNAVAILABLE",
                message:"Unknown method: \(call.method)",
                details:nil))
        }
    }

    private func getChannelId(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(Airship.channel.identifier)
    }

    private func setUserNotificationsEnabled(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let enable = call.arguments as! Bool

        if (enable) {
            Airship.push.enableUserPushNotifications({ (success) in
                result(success)
            })
        } else {
            Airship.push.userPushNotificationsEnabled = false
            result(true)
        }
    }

    private func takeOff(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        guard let args = call.arguments as? [String: String] else {
            result(false)
            return
        }
        
        PluginConfig.appKey = args["app_key"]
        PluginConfig.appSecret = args["app_secret"]
        AirshipAutopilot.attemptTakeOff()
        
        result(Airship.isFlying)
    }
        
    private func getUserNotificationsEnabled(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(Airship.push.userPushNotificationsEnabled)
    }

    private func getActiveNotifications(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        UNUserNotificationCenter.current().getDeliveredNotifications { (notifications) in

            let airshipNotifications = NSMutableArray()

            for notification in notifications {
                let content = notification.request.content
                airshipNotifications.add(content.userInfo)
            }

            result(airshipNotifications)
        }

    }

    private func clearNotification(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let identifier = call.arguments as! String
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers:[identifier])
        result(nil)
    }

    private func clearNotifications(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        result(nil)
    }

    private func addEvent(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let event = call.arguments as? Dictionary<String, Any> else {
            result(nil)
            return
        }

        guard let name = event[eventNameKey] as? String else {
            result(nil)
            return
        }

        guard let value = event[eventValueKey] as? Int else {
            result(nil)
            return
        }

        // Decode event string
        let customEvent = CustomEvent(name:name, value:NSNumber(value: value))

        if let properties = event[propertiesKey] as? Dictionary<String, Any> {
            customEvent.properties = properties
        }

        if let transactionID = event[transactionIDKey] as? String {
            customEvent.transactionID = transactionID
        }

        if let interactionID = event[interactionIDKey] as? String {
            customEvent.interactionID = interactionID
        }

        if let interactionType = event[interactionTypeKey] as? String {
            customEvent.interactionType = interactionType
        }

        if customEvent.isValid() {
            customEvent.track()
            result(true)
        } else {
            result(false)
        }
    }

    private func addTags(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let tags = call.arguments as! [String]
        Airship.channel.editTags { editor in
            editor.add(tags)
            editor.apply()
        }
        Airship.channel.updateRegistration()
        result(nil)
    }

    private func removeTags(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let tags = call.arguments as! [String]
        Airship.channel.editTags { editor in
            editor.remove(tags)
            editor.apply()
        }
        Airship.channel.updateRegistration()
        result(nil)
    }

    private func getTags(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(Airship.channel.tags)
    }

    private func editChannelAttributes(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let operations = call.arguments as! [Dictionary<String, Any>]
        
        Airship.channel.editAttributes { editor in
            for operation in operations {
                guard let operationType = operation[attributeOperationType] as? String else { continue }
                guard let name = operation[attributeOperationKey] as? String else { continue }

                if (operationType == attributeOperationSet) {
                    if let value = operation[attributeOperationValue] as? String {
                        editor.set(string: value, attribute: name)
                        continue
                    }
                    if let value = operation[attributeOperationValue] as? NSNumber, CFGetTypeID(value) == CFNumberGetTypeID() {
                        editor.set(number: value, attribute: name)
                        continue
                    }
                } else if (operationType == attributeOperationRemove) {
                    editor.remove(name)
                }
            }
            editor.apply()
        }
        
        result(nil)
    }

    private func editNamedUserAttributes(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let operations = call.arguments as! [Dictionary<String, Any>]
        
        Airship.contact.editAttributes { editor in
            for operation in operations {
                guard let operationType = operation[attributeOperationType] as? String else { continue }
                guard let name = operation[attributeOperationKey] as? String else { continue }

                if (operationType == attributeOperationSet) {
                    if let value = operation[attributeOperationValue] as? String {
                        editor.set(string: value, attribute: name)
                        continue
                    }
                    if let value = operation[attributeOperationValue] as? NSNumber, CFGetTypeID(value) == CFNumberGetTypeID() {
                        editor.set(number: value, attribute: name)
                        continue
                    }
                } else if (operationType == attributeOperationRemove) {
                    editor.remove(name)
                }
            }
            editor.apply()
        }
        
        result(nil)
    }
    
    private func editNamedUserTagGroups(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let operations = call.arguments as! [Dictionary<String, Any>]

        for operation in operations {
            let group = operation[tagOperationGroupName] as! String
            let operationType = operation[tagOperationType] as! String
            let tags = operation[tagOperationTags] as! [String]
            
            Airship.contact.editTagGroups() { editor in
                if (operationType == tagOperationAdd) {
                    editor.add(tags, group: group)
                } else if (operationType == tagOperationRemove) {
                    editor.remove(tags, group: group)
                } else if (operationType == tagOperationSet) {
                    editor.set(tags, group: group)
                }
                editor.apply()
            }
        }
        
        result(nil)
    }

    private func editChannelTagGroups(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let operations = call.arguments as! [Dictionary<String, Any>]

        for operation in operations {
            let group = operation[tagOperationGroupName] as! String
            let operationType = operation[tagOperationType] as! String
            let tags = operation[tagOperationTags] as! [String]
            Airship.channel.editTagGroups() { editor in
                if (operationType == tagOperationAdd) {
                    editor.add(tags, group: group)
                } else if (operationType == tagOperationRemove) {
                    editor.remove(tags, group: group)
                } else if (operationType == tagOperationSet) {
                    editor.set(tags, group: group)
                }
                editor.apply()
            }
        }

        Airship.push.updateRegistration()
        result(nil)
    }

    private func setNamedUser(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let namedUser = call.arguments as? String else {
            Airship.contact.reset()
            result(nil)
            return
        }
        Airship.contact.identify(namedUser)
        result(nil)
    }

    private func getNamedUser(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(Airship.contact.namedUserID)
    }

    private func getInboxMessages(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let messages = MessageCenter.shared.messageList.messages.map { (message) -> String in
            var payload = ["title": message.title,
                           "message_id": message.messageID,
                           "sent_date": Utils.isoDateFormatterUTCWithDelimiter().string(from: message.messageSent),
                           "is_read": !message.unread,
                           "extras": message.extra] as [String : Any]


            if let icons = message.rawMessageObject["icons"] as? [String:Any] {
                if let listIcon = icons["list_icon"] {
                    payload["list_icon"] = listIcon
                }
            }

            if let expiration = message.messageExpiration {
                payload["expiration_date"] = Utils.isoDateFormatterUTCWithDelimiter().string(from: expiration)
            }

            let data = try! JSONSerialization.data(withJSONObject: payload as Any, options: [])
            return String(data: data, encoding: .utf8)!
        }

        result(messages)
    }

    private func markInboxMessageRead(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let message = MessageCenter.shared.messageList.message(forID: call.arguments as! String)
        MessageCenter.shared.messageList.markMessagesRead([message as Any]) {
            result(nil)
        }
    }

    private func refreshInbox(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        MessageCenter.shared.messageList.retrieveMessageList(successBlock: {
            result(true)
        }, withFailureBlock: {
            result(false)
        })
    }

    private func deleteInboxMessage(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let message = MessageCenter.shared.messageList.message(forID: call.arguments as! String)
        MessageCenter.shared.messageList.markMessagesDeleted([message as Any]) {
            result(nil)
        }
    }

    private func loadCustomNotificationCategories() {
        guard let categoriesPath = Bundle.main.path(forResource: "UACustomNotificationCategories", ofType: "plist") else { return }
        let customNotificationCategories = NotificationCategories.createCategories(fromFile: categoriesPath)

        if customNotificationCategories.count != 0 {
            Airship.push.customCategories = customNotificationCategories
            Airship.push.updateRegistration()
        }
    }

    private func setInAppAutomationPaused(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let paused = call.arguments as! Bool

        InAppAutomation.shared.isPaused = paused
        result(true)
    }

    private func getInAppAutomationPaused(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(InAppAutomation.shared.isPaused)
    }

    private func enableChannelCreation(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        Airship.channel.enableChannelCreation()
        result(nil)
    }
    
    private func trackScreen(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let screen = call.arguments as! String
        
        Airship.analytics.trackScreen(screen)
        result(nil)
    }

    private func setBadge(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let badge = call.arguments as! Int
        Airship.push.badgeNumber = badge
        result(nil)
    }
    
    private func resetBadge(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        Airship.push.resetBadge()
        result(nil)
    }
    
    private func setAutoBadgeEnabled(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let enable = call.arguments as! Bool
        Airship.push.autobadgeEnabled = enable
        result(nil)
    }
    
    private func isAutoBadgeEnabled(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(Airship.push.autobadgeEnabled)
    }
    
    private func enableFeatures(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let featureArray = call.arguments as? Array<String> else {
            result(nil)
            return
        }
        
        var features: Features = []
        for feature in featureArray {
            if let featureName = FeatureNames(rawValue: feature) {
                features.update(with: featureName.toFeature())
            }
        }
        Airship.shared.privacyManager.enableFeatures(features)
        result(nil)
    }
    
    private func disableFeatures(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let featureArray = call.arguments as? Array<String> else {
            result(nil)
            return
        }
        
        var features: Features = []
        for feature in featureArray {
            if let featureName = FeatureNames(rawValue: feature) {
                features.update(with: featureName.toFeature())
            }
        }
        
        Airship.shared.privacyManager.disableFeatures(features)
        result(nil)
    }
    
    private func setEnabledFeatures(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let featureArray = call.arguments as? Array<String> else {
            result(nil)
            return
        }
        
        var features: Features = []
        for feature in featureArray {
            if let featureName = FeatureNames(rawValue: feature) {
                features.update(with: featureName.toFeature())
            }
        }
        
        Airship.shared.privacyManager.enabledFeatures = features
        result(nil)
    }
    
    private func getEnabledFeatures(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let features = Airship.shared.privacyManager.enabledFeatures
        
        var featureArray: [String] = []
        
        if features == Features.all {
            result(Features.all.toString())
            return
        }
        if features == [] {
            result(FeatureNames.none.rawValue)
            return
        }
        
        for featureName in FeatureNames.allCases {
            let feature = featureName.toFeature()
            if ((feature.rawValue & features.rawValue) != 0) && (feature != Features.all) {
                featureArray.append(featureName.rawValue)
            }
        }
        
        result(featureArray)
    }
    
    private func isFeatureEnabled(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let feature = call.arguments as? String else {
            result(nil)
            return
        }
        if let featureName = FeatureNames(rawValue: feature) {
            result(Airship.shared.privacyManager.isEnabled(featureName.toFeature()))
        }
    }
    
    private func openPreferenceCenter(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let preferenceCenterID = call.arguments as? String else {
            result(nil)
            return
        }
        
        if (UserDefaults.standard.bool(forKey: autoLaunchPreferenceCenterKey) == true) {
            PreferenceCenter.shared.open(preferenceCenterID)
        } else {
            let event = AirshipShowPreferenceCenterEvent(preferenceCenterID)
            AirshipEventManager.shared.notify(event)
        }
        result(nil)
    }
    
    private func getSubscriptionLists(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let subscriptionTypes = call.arguments as! [String]
        
        if (subscriptionTypes.count == 0) {
            return
        }
        
        var subscriptionLists: Dictionary<String, Any> = [:]
        let dispatchGroup = DispatchGroup()
        
        if (subscriptionTypes.contains("channel")) {
            dispatchGroup.enter()
            Airship.channel.fetchSubscriptionLists { lists, error in
                subscriptionLists["channel"] = lists ?? []
                dispatchGroup.leave()
            }
        }
        if (subscriptionTypes.contains("contact")) {
            dispatchGroup.enter()
            Airship.contact.fetchSubscriptionLists { lists, error in
                guard let lists = lists else {
                    subscriptionLists["contact"] = [:]
                    dispatchGroup.leave()
                    return
                }
                let listDict = lists.mapValues { value in
                    return value.values.map { $0.stringValue }
                }
                subscriptionLists["contact"] = listDict
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main, execute: {
            result(subscriptionLists)
        })
    }
    
    private func editChannelSubscriptionLists(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let subscriptionLists = call.arguments as! [[String:String]]
        
        let editor = Airship.channel.editSubscriptionLists()
        
        for subscription in subscriptionLists {
            if let listId = subscription["listId"], let listType = subscription["type"] {
                if listType == "subscribe" {
                    editor.subscribe(listId)
                }
                if listType == "unsubscribe" {
                    editor.unsubscribe(listId)
                }
            }
        }
        
        editor.apply()
        
        result(nil)
    }
    
    private func editContactSubscriptionLists(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let subscriptionLists = call.arguments as! [[String:Any]]
        
        let editor = Airship.contact.editSubscriptionLists()
        
        for subscription in subscriptionLists {
            if let listId = subscription["listId"] as? String, let listType = subscription["type"] as? String, let scopes = subscription["scopes"] as? [String] {
                if listType == "subscribe" {
                    for scope in scopes {
                        do {
                            try editor.subscribe(listId, scope:ChannelScope.fromString(scope))
                        }
                        catch {
                            result(FlutterError(code:"INVALID_SCOPE",
                                              message:"Subscription List scope is invalid.",
                                               details: nil))
                        }
                    }
                }
                if listType == "unsubscribe" {
                    for scope in scopes {
                        do {
                            try editor.unsubscribe(listId, scope:ChannelScope.fromString(scope))
                        }
                        catch {
                            result(FlutterError(code:"INVALID_SCOPE",
                                              message:"Subscription List scope is invalid.",
                                               details: nil))
                        }
                    }
                }
            }
        }
        
        result(nil)
    }
    
    private func getPreferenceCenterConfig(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let preferenceCenterID = call.arguments as? String else {
            result(nil)
            return
        }
        
        PreferenceCenter.shared.config(preferenceCenterID: preferenceCenterID) { config in
            guard let config = config else {
                result(nil)
                return
            }
            result(self.configDict(config:config))
        }
    }
    
    private func configDict(config: PreferenceCenterConfig) -> Dictionary<String, Any> {
        var configDict: Dictionary<String, Any> = [:]
        configDict.updateValue(config.identifier, forKey: "identifier")
        let sections = config.sections
        
        var sectionArray: [Any] = []

        for section in sections {
            var sectionDict: Dictionary<String, Any> = [:]
            sectionDict.updateValue(section.identifier, forKey: "identifier")
            
            let items = section.items
            
            var itemArray: [Any] = []
            
            for item in items {
                var itemDict: Dictionary<String, Any> = [:]
                itemDict.updateValue(item.identifier, forKey: "identifier")
                itemDict.updateValue(item.itemType.description, forKey: "type")
                
                if (item.itemType == .channelSubscription) {
                    let subscriptionItem = item as! ChannelSubscriptionItem
                    itemDict.updateValue(subscriptionItem.subscriptionID, forKey:"subscription_id")
                } else if (item.itemType == .contactSubscription) {
                    let subscriptionItem = item as! ContactSubscriptionItem
                    itemDict.updateValue(subscriptionItem.subscriptionID, forKey:"subscription_id")
                } else if (item.itemType == .contactSubscriptionGroup) {
                    let subscriptionItem = item as! ContactSubscriptionGroupItem
                    itemDict.updateValue(subscriptionItem.subscriptionID, forKey:"subscription_id")
                    
                    let components = subscriptionItem.components
                    
                    var componentArray: [Any] = []
                    for component in components {
                        var componentDict: Dictionary<String, Any> = [:]
                        componentDict.updateValue(component.scopes.values.map {$0.stringValue}, forKey: "scopes")
                        
                        if let title = component.display.title {
                            componentDict.updateValue(title, forKey: "title")
                        }
                        if let subtitle = component.display.subtitle {
                            componentDict.updateValue(subtitle, forKey: "subtitle")
                        }
                        componentArray.append(componentDict)
                    }
                    itemDict.updateValue(componentArray, forKey: "components")
                }
                itemArray.append(itemDict)
            }
            
            sectionDict.updateValue(itemArray, forKey: "items")
            if let display = section.display, let title = display.title {
                sectionDict.updateValue(title, forKey: "title")
            }
            if let display = section.display, let subtitle = display.subtitle {
                sectionDict.updateValue(subtitle, forKey: "subtitle")
            }
            
            sectionArray.append(sectionDict)
        }
        
        configDict.updateValue(sectionArray, forKey: "sections")
        if let display = config.display, let title = display.title {
            configDict.updateValue(title, forKey: "title")
        }
        if let display = config.display, let subtitle = display.subtitle {
            configDict.updateValue(subtitle, forKey: "subtitle")
        }
        return configDict
    }
    
    private func setAutoLaunchDefaultPreferenceCenter(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let enabled = call.arguments as? Bool else {
            result(nil)
            return
        }
        
        UserDefaults.standard.set(enabled, forKey: autoLaunchPreferenceCenterKey)
    }
    
    private enum CloudSiteNames : String {
        case eu
        case us
        
        func toSite() -> CloudSite {
            switch (self) {
            case .eu:
                return CloudSite.eu
            case .us:
                return CloudSite.us
            }
        }
    }
}


public enum FeatureNames : String, CaseIterable {
    case push = "FEATURE_PUSH"
    case chat = "FEATURE_CHAT"
    case contacts = "FEATURE_CONTACTS"
    case location = "FEATURE_LOCATION"
    case messageCenter = "FEATURE_MESSAGE_CENTER"
    case analytics = "FEATURE_ANALYTICS"
    case tagsAndAttributes = "FEATURE_TAGS_AND_ATTRIBUTES"
    case inAppAutomation = "FEATURE_IN_APP_AUTOMATION"
    case none = "FEATURE_NONE"
    case all = "FEATURE_ALL"
    
    func toFeature() -> Features {
        switch self {
        case .push:
            return Features.push
        case .chat:
            return Features.chat
        case .contacts:
            return Features.contacts
        case .location:
            return Features.location
        case .messageCenter:
            return Features.messageCenter
        case .analytics:
            return Features.analytics
        case .tagsAndAttributes:
            return Features.tagsAndAttributes
        case .inAppAutomation:
            return Features.inAppAutomation
        case .all:
            return Features.all
        default:
            return []
        }
    }
}

extension Features {
    func toString() -> String {
        switch self {
        case .push:
            return FeatureNames.push.rawValue
        case .chat:
            return FeatureNames.chat.rawValue
        case .contacts:
            return FeatureNames.contacts.rawValue
        case .location:
            return FeatureNames.location.rawValue
        case .messageCenter:
            return FeatureNames.messageCenter.rawValue
        case .analytics:
            return FeatureNames.analytics.rawValue
        case .tagsAndAttributes:
            return FeatureNames.tagsAndAttributes.rawValue
        case .inAppAutomation:
            return FeatureNames.inAppAutomation.rawValue
        case .all:
            return FeatureNames.all.rawValue
        default:
            return ""
        }
    }
}

