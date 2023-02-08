import Flutter
import UIKit
import AirshipKit
import AirshipFrameworkProxy

// TODO: proxy updates
// - Add subtitle to push payload
// - Add proper addCustomEvent method

public class SwiftAirshipPlugin: NSObject, FlutterPlugin {
    private static let eventNames: [AirshipProxyEventType: String] = [
        .deepLinkReceived: "com.airship.flutter/event/deep_link_received",
        .channelCreated: "com.airship.flutter/event/channel_created",
        .pushTokenReceived: "com.airship.flutter/event/.push_token_received",
        .messageCenterUpdated: "com.airship.flutter/event/message_center_updated",
        .displayMessageCenter: "com.airship.flutter/event/display_message_center",
        .displayPreferenceCenter: "com.airship.flutter/event/display_preference_center",
        .notificationResponseReceived: "com.airship.flutter/event/notification_response",
        .pushReceived: "com.airship.flutter/event/push_received",
        .notificationOptInStatusChanged: "com.airship.flutter/event/notification_opt_in_status"
    ]

    private static let streams: [AirshipProxyEventType: AirshipEventStream] = {
        var streams: [AirshipProxyEventType: AirshipEventStream] = [:]
        SwiftAirshipPlugin.eventNames.forEach { (key: AirshipProxyEventType, value: String) in
            streams[key] = AirshipEventStream(key, name: value)
        }
        return streams
    }()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.airship.flutter/airship",
            binaryMessenger: registrar.messenger()
        )
        
        Task {
            let stream = await AirshipProxyEventEmitter.shared.pendingEventTypeAdded
            for await eventType in stream {
                await self.streams[eventType]?.processPendingEvents()
            }
        }
        
        let instance = SwiftAirshipPlugin()
        
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        self.streams.values.forEach { stream in
            stream.register(registrar: registrar)
        }
        
        registrar.register(AirshipInboxMessageViewFactory(registrar), withId: "com.airship.flutter/InboxMessageView")
        registrar.addApplicationDelegate(instance)
    }

    public func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) -> Bool {
        completionHandler(.noData)
        return true
    }
    
    // MARK: - handle methods call
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        Task {
            do {
               result(
                try await handle(call)
               )
            } catch {
                result(
                    FlutterError(
                        code:"AIRSHIP_ERROR",
                        message:error.localizedDescription,
                        details:"Method: \(call.method)"
                    )
                )
            }
        }
    }
    
    @MainActor
    private func handle(_ call: FlutterMethodCall) async throws -> Any? {
        switch call.method {
            
        // Flutter
        case "startBackgroundIsolate":
            return true

        // Airship
        case "takeOff":
            return try AirshipProxy.shared.takeOff(
                json: try call.requireAnyArg(),
                launchOptions: AirshipAutopilot.shared.launchOptions
            )
            
        case "isFlying":
            return AirshipProxy.shared.isFlying()
            
        // Channel
        case "channel#getChannelId":
            return try AirshipProxy.shared.channel.getChannelId()
            
        case "channel#addTags":
            return try AirshipProxy.shared.channel.addTags(
                try call.requireStringArrayArg()
            )
            
        case "channel#removeTags":
            return try AirshipProxy.shared.channel.removeTags(
                try call.requireStringArrayArg()
            )
        
        case "channel#getTags":
            return try AirshipProxy.shared.channel.getTags()
            
        case "channel#editTagGroups":
            return try AirshipProxy.shared.channel.editTagGroups(
                json: try call.requireAnyArg()
            )
            
        case "channel#editSubscriptionLists":
            return try AirshipProxy.shared.channel.editSubscriptionLists(
                json: try call.requireAnyArg()
            )
            
        case "channel#editAttributes":
            return try AirshipProxy.shared.channel.editAttributes(
                json: try call.requireAnyArg()
            )
        
        case "channel#getSubscriptionLists":
            return try await AirshipProxy.shared.channel.getSubscriptionLists()
    
            
        // Contact
        case "contact#editTagGroups":
            return try AirshipProxy.shared.contact.editTagGroups(
                json: try call.requireAnyArg()
            )
            
        case "contact#editSubscriptionLists":
            return try AirshipProxy.shared.contact.editSubscriptionLists(
                json: try call.requireAnyArg()
            )
            
        case "contact#editAttributes":
            return try AirshipProxy.shared.contact.editAttributes(
                json: try call.requireAnyArg()
            )
        
        case "contact#getSubscriptionLists":
            return try await AirshipProxy.shared.contact.getSubscriptionLists()
        
        case "contact#identify":
            return try AirshipProxy.shared.contact.identify(
                try call.requireStringArg()
            )
        
        case "contact#reset":
            return try AirshipProxy.shared.contact.reset()
        
        case "contact#getNamedUserId":
            return try AirshipProxy.shared.contact.getNamedUser()
        
    
        // Push
        case "push#setUserNotificationsEnabled":
            return try AirshipProxy.shared.push.setUserNotificationsEnabled(
                try call.requireBooleanArg()
            )
        
        case "push#enableUserNotifications":
            return try await AirshipProxy.shared.push.enableUserPushNotifications()
            
        case "push#isUserNotifictionsEnabled":
            return try AirshipProxy.shared.push.isUserNotificationsEnabled()
        
        case "push#getNotificationStatus":
            return try AirshipProxy.shared.push.getNotificationStatus()
            
        case "push#getActiveNotifications":
            return await AirshipProxy.shared.push.getActiveNotifications()
            
        case "push#clearNotification":
            return AirshipProxy.shared.push.clearNotification(
                try call.requireStringArg()
            )
            
        case "push#clearNotifications":
            AirshipProxy.shared.push.clearNotifications()
            return nil
            
        case "push#ios#getBadgeNumber":
            return try AirshipProxy.shared.push.getBadgeNumber()
            
        case "push#ios#setBadgeNumber":
            return try AirshipProxy.shared.push.setBadgeNumber(
                try call.requireIntArg()
            )

        case "push#ios#setAutobadgeEnabled":
            return try AirshipProxy.shared.push.setAutobadgeEnabled(
                try call.requireBooleanArg()
            )
            
        case "push#ios#isAutobadgeEnabled":
            return try AirshipProxy.shared.push.isAutobadgeEnabled()
            
        case "push#ios#setNotificationOptions":
            return try AirshipProxy.shared.push.setNotificationOptions(
                names: try call.requireStringArrayArg()
            )

        case "push#ios#setForegroundPresentationOptions":
            return try AirshipProxy.shared.push.setForegroundPresentationOptions(
                names: try call.requireStringArrayArg()
            )

        // In-App
        case "inApp#setPaused":
            return try AirshipProxy.shared.inApp.setPaused(
                try call.requireBooleanArg()
            )
            
        case "inApp#isPaused":
            return try AirshipProxy.shared.inApp.isPaused()
            
        case "inApp#setDisplayInterval":
            return try AirshipProxy.shared.inApp.setDisplayInterval(
                try call.requireIntArg()
            )
            
        case "inApp#getDisplayInterval":
            return try AirshipProxy.shared.inApp.getDisplayInterval()

        // Analytics
        case "analytics#trackScreen":
            return try AirshipProxy.shared.analytics.trackScreen(
                call.arguments as? String
            )
            
        case "analytics#addEvent":
            // TODO
            return nil
            
        case "analytics#associateIdentifier":
            let args = try call.requireStringArrayArg()
            guard args.count == 1 || args.count == 2 else { throw AirshipErrors.error("Call requires 1 to 2 strings.")}
            return try AirshipProxy.shared.analytics.associateIdentifier(
                identifier: args.count == 2 ? args[1] : nil,
                key: args[0]
            )
        
        // Message Center
        case "messageCenter#getMessages":
            return try AirshipProxy.shared.messageCenter.getMessagesJSON()
            
        case "messageCenter#display":
            return try AirshipProxy.shared.messageCenter.display(
                messageID: call.arguments as? String
            )
            
        case "messageCenter#markMessageRead":
            return try await AirshipProxy.shared.messageCenter.markMessageRead(
                messageID: call.requireStringArg()
            )
            
        case "messageCenter#deleteMessage":
            return try await AirshipProxy.shared.messageCenter.deleteMessage(
                messageID: call.requireStringArg()
            )
            
        case "messageCenter#getUnreadMessageCount":
            return try await AirshipProxy.shared.messageCenter.getUnreadCount()
            
        case "messageCenter#refreshMessages":
            return try await AirshipProxy.shared.messageCenter.refresh()

        case "messageCenter#setAutoLaunch":
            return AirshipProxy.shared.messageCenter.setAutoLaunchDefaultMessageCenter(
                try call.requireBooleanArg()
            )
        
        // Preference Center
        case "preferenceCenter#display":
            return try AirshipProxy.shared.preferenceCenter.displayPreferenceCenter(
                preferenceCenterID: try call.requireStringArg()
            )
        case "preferenceCenter#getConfig":
            return try await AirshipProxy.shared.preferenceCenter.getPreferenceCenterConfig(
                preferenceCenterID: try call.requireStringArg()
            )
            
        case "preferenceCenter#setAutoLaunch":
            let args = try call.requireArrayArg()
            guard
                args.count == 2,
                let identifier = args[0] as? String,
                let autoLaunch = args[1] as? Bool
            else {
                throw AirshipErrors.error("Call requires [String, Bool]")
            }

            return AirshipProxy.shared.preferenceCenter.setAutoLaunchPreferenceCenter(
                autoLaunch,
                preferenceCenterID: identifier
            )
            
        // Privacy Manager
        case "privacyManager#setEnabledFeatures":
            return try AirshipProxy.shared.privacyManager.setEnabled(
                featureNames: try call.requireStringArrayArg()
            )
            
        case "privacyManager#getEnabledFeatures":
            return try AirshipProxy.shared.privacyManager.getEnabledNames()
            
        case "privacyManager#enableFeatures":
            return try AirshipProxy.shared.privacyManager.enable(
                featureNames: try call.requireStringArrayArg()
            )
            
        case "privacyManager#disableFeatures":
            return try AirshipProxy.shared.privacyManager.disable(
                featureNames: try call.requireStringArrayArg()
            )
            
        case "privacyManager#isFeaturesEnabled":
            return try AirshipProxy.shared.privacyManager.isEnabled(
                featuresNames: try call.requireStringArrayArg()
            )
            

        // Locale
        case "locale#setLocaleOverride":
            return try AirshipProxy.shared.locale.setCurrentLocale(
                try call.requireStringArg()
            )
            
        case "locale#clearLocaleOverride":
            return try AirshipProxy.shared.locale.clearLocale()
            
        case "locale#getCurrentLocale":
            return try AirshipProxy.shared.locale.getCurrentLocale()

        // Actions
        case "actions#run":
            let args = try call.requireArrayArg()
            guard
                args.count == 1 || args.count == 2,
                let actionName = args[0] as? String
            else {
                throw AirshipErrors.error("Call requires [String, Any?]")
            }

            return try await AirshipProxy.shared.action.runAction(
                actionName,
                actionValue: args.count == 2 ? args[1] : nil
            )

        default:
            return FlutterError(
                code:"UNAVAILABLE",
                message:"Unknown method: \(call.method)",
                details:nil
            )
        }
    }
}

extension FlutterMethodCall {
    func requireArrayArg() throws -> [Any] {
        guard let args = self.arguments as? [Any] else {
            throw AirshipErrors.error("Argument must be an array")
        }
        
        return args
    }
    
    func requireStringArrayArg() throws -> [String] {
        guard let args = self.arguments as? [String] else {
            throw AirshipErrors.error("Argument must be a string array")
        }
        
        return args
    }
    
    func requireAnyArg() throws -> Any {
        guard let args = self.arguments else {
            throw AirshipErrors.error("Argument must not be null")
        }
        
        return args
    }
    
    func requireBooleanArg() throws -> Bool {
        guard let args = self.arguments as? Bool else {
            throw AirshipErrors.error("Argument must be a boolean")
        }
        
        return args
    }
    
    func requireStringArg() throws -> String {
        guard let args = self.arguments as? String else {
            throw AirshipErrors.error("Argument must be a string")
        }
        
        return args
    }
    
    func requireIntArg() throws -> Int {
        if let int = self.arguments as? Int {
            return int
        }
        
        if let double = self.arguments as? Double {
            return Int(double)
        }
        
        if let number = self.arguments as? NSNumber {
            return number.intValue
        }
        
        throw AirshipErrors.error("Argument must be an int")
    }
    
    func requireDoubleArg() throws -> Double {
        if let double = self.arguments as? Double {
            return double
        }
        
        if let int = self.arguments as? Int {
            return Double(int)
        }
        
        if let number = self.arguments as? NSNumber {
            return number.doubleValue
        }
        
        
        throw AirshipErrors.error("Argument must be a double")
    }
}

internal class AirshipEventStream : NSObject, FlutterStreamHandler {

    private var eventSink : FlutterEventSink?
    private let eventType: AirshipProxyEventType
    private let lock = Lock()
    private let name: String
    
    init(_ eventType: AirshipProxyEventType, name: String) {
        self.eventType = eventType
        self.name = name
    }

    private func notify(_ event: AirshipProxyEvent) -> Bool {
        var result = false
        lock.sync {
            if let sink = self.eventSink {
                sink(event.body)
                result = true
            }
        }
        
        return result
    }
    
    func register(registrar: FlutterPluginRegistrar) {
        let eventChannel = FlutterEventChannel(
            name: self.name,
            binaryMessenger: registrar.messenger()
        )
        eventChannel.setStreamHandler(self)
    }
    
    func processPendingEvents() async {
        await AirshipProxyEventEmitter.shared.processPendingEvents(
            type: eventType,
            handler: { event in
                return self.notify(event)
            }
        )
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        lock.sync {
            self.eventSink = nil
        }
        
        return nil
    }

    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        lock.sync {
            self.eventSink = events
        }
        
        Task {
           await processPendingEvents()
        }
        
        return nil
    }
}
