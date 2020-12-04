import Flutter
import UIKit
import Airship

public class SwiftAirshipPlugin: NSObject, FlutterPlugin, UARegistrationDelegate,
UADeepLinkDelegate, UAPushNotificationDelegate {
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

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.airship.flutter/airship",
                                           binaryMessenger: registrar.messenger())

        let instance = SwiftAirshipPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        AirshipEventManager.shared.register(registrar)
        instance.takeOff()

        registrar.register(AirshipInboxMessageViewFactory(registrar), withId: "com.airship.flutter/InboxMessageView")
    }

    public func takeOff() {
        UAirship.takeOff()
        UAirship.push()?.registrationDelegate = self
        UAirship.shared()?.deepLinkDelegate = self
        UAirship.push()?.pushNotificationDelegate = self

        UAirship.analytics()?.register(UASDKExtension.flutter, version: AirshipPluginVersion.pluginVersion)

        UAirship.push()?.defaultPresentationOptions = [.alert]
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(inboxUpdated),
                                               name: NSNotification.Name.UAInboxMessageListUpdated,
                                               object: nil)

        self.loadCustomNotificationCategories()
    }

    public func registrationSucceeded(forChannelID channelID: String, deviceToken: String) {
        let event = AirshipChannelRegistrationEvent(channelID, registrationToken: deviceToken)
        AirshipEventManager.shared.notify(event)
    }

    public func receivedDeepLink(_ url: URL, completionHandler: @escaping () -> Void) {
        let event = AirshipDeepLinkEvent(url.absoluteString)
        AirshipEventManager.shared.notify(event)
        completionHandler()
    }

    public func receivedForegroundNotification(_ notificationContent: UANotificationContent, completionHandler: @escaping () -> Void) {
        let event = AirshipPushReceivedEvent(notificationContent)
        AirshipEventManager.shared.notify(event)
        completionHandler()
    }

    public func receivedBackgroundNotification(_ notificationContent: UANotificationContent, completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let event = AirshipPushReceivedEvent(notificationContent)
        AirshipEventManager.shared.notify(event)
        completionHandler(.noData)
    }

    public func receivedNotificationResponse(_ notificationResponse: UANotificationResponse, completionHandler: @escaping () -> Void) {
        let event = AirshipNotificationResponseEvent(notificationResponse)
        AirshipEventManager.shared.notify(event)
        completionHandler()
    }

    @objc
    public func showInbox() {
        let event = AirshipShowInboxEvent()
        AirshipEventManager.shared.notify(event)
    }

    public func showMessage(forID messageID: String) {
        let event = AirshipShowInboxMessageEvent(messageID)
        AirshipEventManager.shared.notify(event)
    }

    @objc public func inboxUpdated() {
        let event = AirshipInboxUpdatedEvent()
        AirshipEventManager.shared.notify(event)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
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
        case "getDataCollectionEnabled":
            getDataCollectionEnabled(call, result: result)
        case "getPushTokenRegistrationEnabled":
            getPushTokenRegistrationEnabled(call, result: result)
        case "setDataCollectionEnabled":
            setDataCollectionEnabled(call, result: result)
        case "setPushTokenRegistrationEnabled":
            setPushTokenRegistrationEnabled(call, result: result)
        case "refreshInbox":
            refreshInbox(call, result: result)
        default:
            result(FlutterError(code:"UNAVAILABLE",
                message:"Unknown method: \(call.method)",
                details:nil))
        }
    }

    private func getChannelId(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(UAirship.channel().identifier)
    }

    private func getDataCollectionEnabled(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(UAirship.shared().isDataCollectionEnabled)
    }

    private func getPushTokenRegistrationEnabled(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(UAPush.shared().pushTokenRegistrationEnabled)
    }

    private func setDataCollectionEnabled(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let enable = call.arguments as! Bool
        UAirship.shared().isDataCollectionEnabled = enable
        result(true)
    }

    private func setPushTokenRegistrationEnabled(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let enable = call.arguments as! Bool
        UAPush.shared().pushTokenRegistrationEnabled = enable
        result(true)
    }

    private func setUserNotificationsEnabled(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let enable = call.arguments as! Bool

        if (enable) {
            UAirship.push()?.enableUserPushNotifications({ (success) in
                result(success)
            })
        } else {
            UAirship.push()?.userPushNotificationsEnabled = false
            result(true)
        }
    }

    private func getUserNotificationsEnabled(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(UAirship.push()?.userPushNotificationsEnabled)
    }

    private func getActiveNotifications(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        UNUserNotificationCenter.current().getDeliveredNotifications { (notifications) in

            let airshipNotifications = NSMutableArray()

            for notification in notifications {
                let content = UANotificationContent.notification(with:notification)
                let pushBody = PushHelpers.pushBodyForNotificationContent(content: content)
                airshipNotifications.add(pushBody)
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
        let customEvent = UACustomEvent(name:name, value:NSNumber(value: value))

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
        UAirship.channel().addTags(tags)
        UAirship.channel().updateRegistration()
        result(nil)
    }

    private func removeTags(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let tags = call.arguments as! [String]
        UAirship.channel().removeTags(tags)
        UAirship.channel().updateRegistration()
        result(nil)
    }

    private func getTags(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(UAirship.channel().tags)
    }

    private func editChannelAttributes(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let operations = call.arguments as! [Dictionary<String, Any>]
        let mutations = mutationsWithOperations(operations: operations)
        
        UAirship.channel()?.apply(mutations)
        
        result(nil)
    }

    private func editNamedUserAttributes(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let operations = call.arguments as! [Dictionary<String, Any>]
        let mutations = mutationsWithOperations(operations: operations)
        
        UAirship.namedUser()?.apply(mutations)
        
        result(nil)
    }
    
    private func editNamedUserTagGroups(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let operations = call.arguments as! [Dictionary<String, Any>]
        let namedUser = UAirship.namedUser()

        for operation in operations {
            let group = operation[tagOperationGroupName] as! String
            let operationType = operation[tagOperationType] as! String
            let tags = operation[tagOperationTags] as! [String]
            if (operationType == tagOperationAdd) {
                namedUser?.addTags(tags, group: group)
            } else if (operationType == tagOperationRemove) {
                namedUser?.removeTags(tags, group: group)
            } else if (operationType == tagOperationSet) {
                namedUser?.setTags(tags, group: group)
            }
        }

        namedUser?.updateTags()
        result(nil)
    }

    private func editChannelTagGroups(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let operations = call.arguments as! [Dictionary<String, Any>]

        for operation in operations {
            let group = operation[tagOperationGroupName] as! String
            let operationType = operation[tagOperationType] as! String
            let tags = operation[tagOperationTags] as! [String]
            if (operationType == tagOperationAdd) {
                UAirship.channel().addTags(tags, group: group)
            } else if (operationType == tagOperationRemove) {
                UAirship.channel().removeTags(tags, group: group)
            } else if (operationType == tagOperationSet) {
                UAirship.channel().setTags(tags, group: group)
            }
        }

        UAirship.push()?.updateRegistration()
        result(nil)
    }

    private func setNamedUser(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let namedUser = call.arguments as? String
        UAirship.namedUser()?.identifier = namedUser
        result(nil)
    }

    private func getNamedUser(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(UAirship.namedUser()?.identifier)
    }

    private func getInboxMessages(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let messages = UAMessageCenter.shared().messageList.messages.map { (message) -> String in
            var payload = ["title": message.title,
                           "message_id": message.messageID,
                           "sent_date": UAUtils.isoDateFormatterUTCWithDelimiter().string(from: message.messageSent),
                           "is_read": !message.unread] as [String : Any]


            if let icons = message.rawMessageObject["icons"] as? [String:Any] {
                if let listIcon = icons["list_icon"] {
                    payload["list_icon"] = listIcon
                }
            }

            if let expiration = message.messageExpiration {
                payload["expiration_date"] = UAUtils.isoDateFormatterUTCWithDelimiter().string(from: expiration)
            }

            let data = try! JSONSerialization.data(withJSONObject: payload as Any, options: [])
            return String(data: data, encoding: .utf8)!
        }

        result(messages)
    }

    private func markInboxMessageRead(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let message = UAMessageCenter.shared().messageList.message(forID: call.arguments as! String)
        UAMessageCenter.shared().messageList.markMessagesRead([message as Any]) {
            result(nil)
        }
    }

    callWebservice("your-service-name", withMethod: "your-method", andParams: ["your-dic-key": "your dict value"], showLoader: true/*or false*/,
    completionBlockSuccess: { (success) -> Void in
        // your successful handle
    }) { (failure) -> Void in
        // your failure handle
    }

    private func refreshInbox(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        UAMessageCenter.shared().messageList.retrieveMessageList() {
            result(true)
        } failureBlock: {
            result(false)
        }
    }

    private func deleteInboxMessage(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let message = UAMessageCenter.shared().messageList.message(forID: call.arguments as! String)
        UAMessageCenter.shared().messageList.markMessagesDeleted([message as Any]) {
            result(nil)
        }
    }

    private func loadCustomNotificationCategories() {
        guard let categoriesPath = Bundle.main.path(forResource: "UACustomNotificationCategories", ofType: "plist") else { return }
        let customNotificationCategories = UANotificationCategories.createCategories(fromFile: categoriesPath) as! Set<UANotificationCategory>

        if customNotificationCategories.count != 0 {
            UAirship.push()?.customCategories = customNotificationCategories
            UAirship.push()?.updateRegistration()
        }
    }

    private func setInAppAutomationPaused(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let paused = call.arguments as! Bool

        UAInAppAutomation.shared().isPaused = paused
        result(true)
    }

    private func getInAppAutomationPaused(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(UAInAppAutomation.shared().isPaused)
    }

    private func enableChannelCreation(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        UAirship.channel()?.enableCreation()
        result(nil)
    }
    
    private func trackScreen(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let screen = call.arguments as! String
        
        UAirship.analytics()?.trackScreen(screen)
        result(nil)
    }
    
    private func mutationsWithOperations(operations:[Dictionary<String, Any>]) -> UAAttributeMutations {
       let mutations:UAAttributeMutations = UAAttributeMutations()
        
        for operation in operations {
            guard let operationType = operation[attributeOperationType] as? String else { continue }
            guard let name = operation[attributeOperationKey] as? String else { continue }

            if (operationType == attributeOperationSet) {
                if let value = operation[attributeOperationValue] as? String {
                    mutations.setString(value, forAttribute: name)
                    continue
                }
                if let value = operation[attributeOperationValue] as? NSNumber, CFGetTypeID(value) == CFNumberGetTypeID() {
                    mutations.setNumber(value, forAttribute: name)
                    continue
                }
            } else if (operationType == attributeOperationRemove) {
                mutations.removeAttribute(name)
            }
        }
        
        return mutations
    }
}

class PushHelpers {
    static func pushBodyForNotificationContent(content:UANotificationContent) -> NSMutableDictionary {
        let pushBody : NSMutableDictionary = NSMutableDictionary()
        pushBody.setValue(content.alertBody, forKey:"alert")
        pushBody.setValue(content.alertTitle, forKey:"title")

        var extras = content.notificationInfo as Dictionary
        let keys = Array(extras.keys)

        if keys.contains("aps") {
            extras.removeValue(forKey:"aps")
        }
        if keys.contains("_") {
            extras.removeValue(forKey:"_")
        }
        if extras.count != 0 {
            pushBody.setValue(extras, forKey:"extras")
        }

        let identifier = content.notification?.request.identifier
        pushBody.setValue(identifier, forKey:"notification_id")

        return pushBody
    }
}
