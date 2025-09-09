import Flutter
import UIKit
import AirshipFrameworkProxy
import Combine

#if canImport(AirshipCore)
import AirshipCore
#else
import AirshipKit
#endif

public class AirshipPlugin: NSObject, FlutterPlugin {
    private static let eventNames: [AirshipProxyEventType: String] = [
        .authorizedNotificationSettingsChanged: "com.airship.flutter/event/ios_authorized_notification_settings_changed",
        .pushTokenReceived: "com.airship.flutter/event/push_token_received",
        .deepLinkReceived: "com.airship.flutter/event/deep_link_received",
        .channelCreated: "com.airship.flutter/event/channel_created",
        .messageCenterUpdated: "com.airship.flutter/event/message_center_updated",
        .displayMessageCenter: "com.airship.flutter/event/display_message_center",
        .displayPreferenceCenter: "com.airship.flutter/event/display_preference_center",
        .notificationResponseReceived: "com.airship.flutter/event/notification_response",
        .pushReceived: "com.airship.flutter/event/push_received",
        .notificationStatusChanged: "com.airship.flutter/event/notification_status_changed",
        .pendingEmbeddedUpdated: "com.airship.flutter/event/pending_embedded_updated",
        .overridePresentationOptions: "com.airship.flutter/event/override_presentation_options"
    ]

    private let streams: [AirshipProxyEventType: AirshipEventStream] = {
        var streams: [AirshipProxyEventType: AirshipEventStream] = [:]
        AirshipPlugin.eventNames.forEach { (key: AirshipProxyEventType, value: String) in
            streams[key] = AirshipEventStream(key, name: value)
        }
        return streams
    }()

    private var subscriptions = Set<AnyCancellable>()


    private let lock = AirshipLock()
    
    var pendingPresentationRequests: [String: PresentationOptionsOverridesRequest] = [:]
    
    @objc
    public var overridePresentationOptionsEnabled: Bool = false {
        didSet {
            if (!overridePresentationOptionsEnabled) {
                lock.sync {
                    self.pendingPresentationRequests.values.forEach { request in
                        request.result(options: nil)
                    }
                    self.pendingPresentationRequests.removeAll()
                }
            }
        }
    }
    
    static let shared = AirshipPlugin()

    @MainActor
    public static func register(with registrar: FlutterPluginRegistrar) {
        AirshipPlugin.shared.setup(registrar: registrar)
    }

    @MainActor
    private func setup(registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.airship.flutter/airship",
            binaryMessenger: registrar.messenger()
        )

        registrar.addMethodCallDelegate(self, channel: channel)

        self.streams.values.forEach { stream in
            stream.register(registrar: registrar)
        }

        registrar.register(AirshipInboxMessageViewFactory(registrar), withId: "com.airship.flutter/InboxMessageView")
        registrar.register(AirshipEmbeddedViewFactory(registrar), withId: "com.airship.flutter/EmbeddedView")

        registrar.addApplicationDelegate(self)

        AirshipProxyEventEmitter.shared.pendingEventPublisher.sink { [weak self] (event: any AirshipProxyEvent) in
            guard let self = self, let stream = self.streams[event.type] else {
                return
            }

            Task {
                await stream.processPendingEvents()
            }
            
        }.store(in: &self.subscriptions)
        
        AirshipProxy.shared.push.presentationOptionOverrides = { request in
            guard self.overridePresentationOptionsEnabled else {
                request.result(options: nil)
                return
            }
            
            let requestID = UUID().uuidString
            self.lock.sync {
                self.pendingPresentationRequests[requestID] = request
            }
            
            if let stream = self.streams[.pushReceived] {
                Task {
                    await stream
/*                         .notify(
                            OverridePresentationOptionsEvent(
                                pushPayload: request.pushPayload,
                                requestId: requestID
                            )
                        ) */
                }
            }
        }
    }
    
    @objc
    public func presentationOptionOverridesResult(requestID: String, presentationOptions: [String]?) {
        lock.sync {
            pendingPresentationRequests[requestID]?.result(optionNames: presentationOptions)
            pendingPresentationRequests[requestID] = nil
        }
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
                let pluginResult = try await handle(call)
                result(pluginResult)
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
            return try AirshipProxy.shared.channel.channelID
            
        case "channel#waitForChannelId":
            return try await AirshipProxy.shared.channel.waitForChannelID()

        case "channel#addTags":
            try AirshipProxy.shared.channel.addTags(
                try call.requireStringArrayArg()
            )
            return nil
            
        case "channel#removeTags":
            try AirshipProxy.shared.channel.removeTags(
                try call.requireStringArrayArg()
            )
            return nil

        case "channel#editTags":
            let operation = try JSONDecoder().decode(
                [TagOperation].self,
                from: try AirshipJSONUtils.data(call.requireAnyArg())
            )

            try AirshipProxy.shared.channel.editTags(
                operations: operation
            )
            return nil

        case "channel#getTags":
            return try AirshipProxy.shared.channel.tags

        case "channel#editTagGroups":
            let operation = try JSONDecoder().decode(
                [TagGroupOperation].self,
                from: try AirshipJSONUtils.data(call.requireAnyArg())
            )

            try AirshipProxy.shared.channel.editTagGroups(
                operations: operation
            )
            return nil
            
        case "channel#editSubscriptionLists":
            try AirshipProxy.shared.channel.editSubscriptionLists(
                json: try call.requireAnyArg()
            )
            return nil
            
        case "channel#editAttributes":
            let operations = try JSONDecoder().decode(
                [AttributeOperation].self,
                from: try AirshipJSONUtils.data(call.requireAnyArg())
            )
            try AirshipProxy.shared.channel.editAttributes(
                operations: operations
            )
            return nil
        
        case "channel#getSubscriptionLists":
            return try await AirshipProxy.shared.channel.fetchSubscriptionLists()
    
            
        // Contact
        case "contact#editTagGroups":
            let operations = try JSONDecoder().decode(
                [TagGroupOperation].self,
                from: try AirshipJSONUtils.data(call.requireAnyArg())
            )
            try AirshipProxy.shared.contact.editTagGroups(
                operations: operations
            )
            return nil
            
        case "contact#editSubscriptionLists":
            let operations = try JSONDecoder().decode(
                [ScopedSubscriptionListOperation].self,
                from: try AirshipJSONUtils.data(call.requireAnyArg())
            )
            try AirshipProxy.shared.contact.editSubscriptionLists(
                operations: operations
            )
            return nil
            
        case "contact#editAttributes":
            let operations = try JSONDecoder().decode(
                [AttributeOperation].self,
                from: try AirshipJSONUtils.data(call.requireAnyArg())
            )

            try AirshipProxy.shared.contact.editAttributes(
                operations: operations
            )
            return nil
        
        case "contact#getSubscriptionLists":
            return try await AirshipProxy.shared.contact.getSubscriptionLists()
        
        case "contact#identify":
            try AirshipProxy.shared.contact.identify(
                try call.requireStringArg()
            )
            return nil
        
        case "contact#reset":
            try AirshipProxy.shared.contact.reset()
            return nil
        
        case "contact#notifyRemoteLogin":
            try AirshipProxy.shared.contact.notifyRemoteLogin()
            return nil

        case "contact#getNamedUserId":
            return try await AirshipProxy.shared.contact.namedUserID

    
        // Push
        case "push#getRegistrationToken":
            return try AirshipProxy.shared.push.getRegistrationToken()
        
        case "push#setUserNotificationsEnabled":
            try AirshipProxy.shared.push.setUserNotificationsEnabled(
                try call.requireBooleanArg()
            )
            return nil
        
        case "push#enableUserNotifications":
            guard let args = try? call.requireAnyArg() as? [String: Any] else {
                throw AirshipErrors.error("Invalid argument type. Expected dictionary.")
            }

            let json = try AirshipJSON.wrap(args)

            if let enableArgs: EnableUserPushNotificationsArgs = try? json.decode() {
                return try? await AirshipProxy.shared.push.enableUserPushNotifications(args: enableArgs)
            } else {
                return try? await AirshipProxy.shared.push.enableUserPushNotifications()
            }

        case "push#isUserNotificationsEnabled":
            return try AirshipProxy.shared.push.isUserNotificationsEnabled()

        case "push#getNotificationStatus":
            return try await AirshipProxy.shared.push.notificationStatus.unwrapped()

        case "push#getActiveNotifications":
            return try await AirshipProxy.shared.push.getActiveNotifications().unwrapped()

        case "push#clearNotification":
            AirshipProxy.shared.push.clearNotification(
                try call.requireStringArg()
            )
            return nil
            
        case "push#clearNotifications":
            AirshipProxy.shared.push.clearNotifications()
            return nil
            
        case "push#ios#getBadgeNumber":
            return try AirshipProxy.shared.push.getBadgeNumber()
            
        case "push#ios#setBadgeNumber":
            try await AirshipProxy.shared.push.setBadgeNumber(
                try call.requireIntArg()
            )
            return nil

        case "push#ios#setAutobadgeEnabled":
            try AirshipProxy.shared.push.setAutobadgeEnabled(
                try call.requireBooleanArg()
            )
            return nil
            
        case "push#ios#isAutobadgeEnabled":
            return try AirshipProxy.shared.push.isAutobadgeEnabled()
        
        case "push#ios#resetBadgeNumber":
            try await AirshipProxy.shared.push.setBadgeNumber(0)
            return nil
            
        case "push#ios#setNotificationOptions":
            try AirshipProxy.shared.push.setNotificationOptions(
                names: try call.requireStringArrayArg()
            )
            return nil

        case "push#ios#setForegroundPresentationOptions":
            try AirshipProxy.shared.push.setForegroundPresentationOptions(
                names: try call.requireStringArrayArg()
            )
            return nil

        case "push#ios#isOverridePresentationOptionsEnabled":
            if let args = call.arguments as? [String: Any],
                let enabled = args["enabled"] as? Bool {
                overridePresentationOptionsEnabled = enabled
            }
            return nil
        
        case "push#ios#isOverridePresentationOptions":
            if let args = call.arguments as? [String: Any],
               let requestID = args["requestId"] as? String,
               let options = args["options"] as? [String]?
            {
                presentationOptionOverridesResult(requestID: requestID, presentationOptions: options)
            }
            return nil
            

        case "push#ios#getAuthorizedNotificationSettings":
            return try AirshipProxy.shared.push.getAuthorizedNotificationSettings()

        case "push#ios#getAuthorizedNotificationStatus":
            return try AirshipProxy.shared.push.getAuthroizedNotificationStatus()


        // In-App
        case "inApp#setPaused":
            try AirshipProxy.shared.inApp.setPaused(
                try call.requireBooleanArg()
            )
            return nil
            
        case "inApp#isPaused":
            return try AirshipProxy.shared.inApp.isPaused()
            
        case "inApp#setDisplayInterval":
            try AirshipProxy.shared.inApp.setDisplayInterval(
                milliseconds: try call.requireIntArg()
            )
            return nil
            
        case "inApp#getDisplayInterval":
            return try AirshipProxy.shared.inApp.getDisplayInterval()

        case "inApp#resendLastEmbeddedEvent":
            AirshipProxy.shared.inApp.resendLastEmbeddedEvent()
            return nil

        // Analytics
        case "analytics#trackScreen":
            try AirshipProxy.shared.analytics.trackScreen(
                call.arguments as? String
            )
            return nil
            
        case "analytics#addEvent":
            try AirshipProxy.shared.analytics.addEvent(
                call.requireAnyArg()
            )
            return nil
            
        case "analytics#associateIdentifier":
            let args = try call.requireStringArrayArg()
            guard args.count == 1 || args.count == 2 else { throw AirshipErrors.error("Call requires 1 to 2 strings.")}
            try AirshipProxy.shared.analytics.associateIdentifier(
                identifier: args.count == 2 ? args[1] : nil,
                key: args[0]
            )
            return nil
        
        // Message Center
        case "messageCenter#getMessages":
            guard
                let messages = try? await AirshipProxy.shared.messageCenter.messages,
                let data = try? JSONEncoder().encode(messages),
                let result = try? JSONSerialization.jsonObject(
                    with: data,
                    options: .fragmentsAllowed
                ) as? [Any]
            else {
                throw AirshipErrors.error("Unable to convert messages to JSON")
            }

            return result

        case "messageCenter#display":
            try AirshipProxy.shared.messageCenter.display(
                messageID: call.arguments as? String
            )
            return nil
            
        case "messageCenter#markMessageRead":
            try await AirshipProxy.shared.messageCenter.markMessageRead(
                messageID: call.requireStringArg()
            )
            return nil
            
        case "messageCenter#deleteMessage":
            try await AirshipProxy.shared.messageCenter.deleteMessage(
                messageID: call.requireStringArg()
            )
            return nil
            
        case "messageCenter#getUnreadMessageCount":
            return try await AirshipProxy.shared.messageCenter.unreadCount

        case "messageCenter#refreshMessages":
            try await AirshipProxy.shared.messageCenter.refresh()
            return nil

        case "messageCenter#setAutoLaunch":
            AirshipProxy.shared.messageCenter.setAutoLaunchDefaultMessageCenter(
                try call.requireBooleanArg()
            )
            return nil

        case "messageCenter#showMessageCenter":
            let optionalMessageId = call.arguments as? String
            try AirshipProxy.shared.messageCenter.showMessageCenter(
                messageID: optionalMessageId
            )
            return nil

        case "messageCenter#showMessageView":
            try AirshipProxy.shared.messageCenter.showMessageView(
                messageID: try call.requireStringArg()
            )
            return nil
        
        // Preference Center
        case "preferenceCenter#display":
            try AirshipProxy.shared.preferenceCenter.displayPreferenceCenter(
                preferenceCenterID: try call.requireStringArg()
            )
            return nil
            
        case "preferenceCenter#getConfig":
            return try await AirshipProxy.shared.preferenceCenter.getPreferenceCenterConfig(
                preferenceCenterID: try call.requireStringArg()
            ).unWrap()
        case "preferenceCenter#setAutoLaunch":
            let args = try call.requireArrayArg()
            guard
                args.count == 2,
                let identifier = args[0] as? String,
                let autoLaunch = args[1] as? Bool
            else {
                throw AirshipErrors.error("Call requires [String, Bool]")
            }

            AirshipProxy.shared.preferenceCenter.setAutoLaunchPreferenceCenter(
                autoLaunch,
                preferenceCenterID: identifier
            )
            return nil
            
        // Privacy Manager
        case "privacyManager#setEnabledFeatures":
            try AirshipProxy.shared.privacyManager.setEnabled(
                featureNames: try call.requireStringArrayArg()
            )
            return nil
            
        case "privacyManager#getEnabledFeatures":
            return try AirshipProxy.shared.privacyManager.getEnabledNames()
            
        case "privacyManager#enableFeatures":
            try AirshipProxy.shared.privacyManager.enable(
                featureNames: try call.requireStringArrayArg()
            )
            return nil
            
        case "privacyManager#disableFeatures":
            try AirshipProxy.shared.privacyManager.disable(
                featureNames: try call.requireStringArrayArg()
            )
            return nil
            
        case "privacyManager#isFeaturesEnabled":
            return try AirshipProxy.shared.privacyManager.isEnabled(
                featuresNames: try call.requireStringArrayArg()
            )

        // Locale
        case "locale#setLocaleOverride":
            try AirshipProxy.shared.locale.setCurrentLocale(
                try call.requireStringArg()
            )
            return nil
            
        case "locale#clearLocaleOverride":
            try AirshipProxy.shared.locale.clearLocale()
            return nil
            
        case "locale#getCurrentLocale":
            return try AirshipProxy.shared.locale.currentLocale

        // Actions
        case "actions#run":
            let args = try call.requireArrayArg()
            guard
                args.count == 1 || args.count == 2,
                let actionName = args[0] as? String
            else {
                throw AirshipErrors.error("Call requires [String, Any?]")
            }

            let arg = try? AirshipJSON.wrap(args[1])
            let result = try await AirshipProxy.shared.action.runAction(
                actionName,
                value: args.count == 2 ? arg : nil
            ) as? AirshipJSON
            return result?.unWrap()

        // Live Activity

        case "liveActivity#start":
             guard let args = try? call.requireAnyArg() as? [String: Any] else {
                 throw AirshipErrors.error("Invalid argument type. Expected dictionary.")
             }


             if #available(iOS 16.1, *) {
                 do {

                     let json = try AirshipJSON.wrap(args)

                     let decoder = JSONDecoder()
                     decoder.dateDecodingStrategy = .iso8601
                     let start:LiveActivityRequest.Start = try json.decode(decoder: decoder)

                     let result = try AirshipJSON.wrap(try await LiveActivityManager.shared.start(start))

                     return result.unWrap()
                 } catch {
                     throw AirshipErrors.error("Unable to start request: \(error.localizedDescription)")
                 }
             } else {
                 throw AirshipErrors.error("Not available before iOS 16.1")
             }

        case "liveActivity#update":
            guard let args = try? call.requireAnyArg() as? [String: Any] else {
                throw AirshipErrors.error("Invalid argument type. Expected dictionary.")
            }


            if #available(iOS 16.1, *) {
                let json = try AirshipJSON.wrap(args)

                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let update:LiveActivityRequest.Update = try json.decode(decoder: decoder)

                try await LiveActivityManager.shared.update(update)

                return nil
            } else {
                throw AirshipErrors.error("Not available before iOS 16.1")
            }
        case "liveActivity#listAll":
            if #available(iOS 16.1, *) {
                let result = try await LiveActivityManager.shared.listAll()
                return try AirshipJSON.wrap(result).unWrap() as Any
            } else {
                throw AirshipErrors.error("Not available before 16.1")
            }

        case "liveActivity#list":
            if #available(iOS 16.1, *) {
                let result = try await LiveActivityManager.shared.list(try AirshipJSON.wrap(call.arguments).decode())
                return try AirshipJSON.wrap(result).unWrap() as Any
            } else {
                throw AirshipErrors.error("Not available before 16.1")
            }
        case "liveActivity#stop":
            guard let args = try? call.requireAnyArg() as? [String: Any] else {
                throw AirshipErrors.error("Invalid argument type. Expected dictionary.")
            }

            if #available(iOS 16.1, *) {
                let json = try AirshipJSON.wrap(args)

                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let request:LiveActivityRequest.End = try json.decode(decoder: decoder)

                try await LiveActivityManager.shared.end(request)

                return nil
            } else {
                throw AirshipErrors.error("Not available before iOS 16.1")
            }

        case "liveUpdate#start":
            throw AirshipErrors.error("Not available on iOS")

        case "liveUpdate#listAll":
            throw AirshipErrors.error("Not available on iOS")

        case "liveUpdate#list":
            throw AirshipErrors.error("Not available on iOS")

        case "liveUpdate#update":
            throw AirshipErrors.error("Not available on iOS")

        case "liveUpdate#end":
            throw AirshipErrors.error("Not available on iOS")

            // Feature Flag
        case "featureFlagManager#flag":
            guard let args = try? call.requireAnyArg() as? [String: Any],
                  let name = args["flagName"] as? String,
                  let useResultCache = args["useResultCache"] as? Bool
            else {
                throw AirshipErrors.error("Invalid arguments")
            }
            let flag = try await AirshipProxy.shared.featureFlagManager.flag(
                name: name,
                useResultCache: useResultCache
            )
            return try AirshipJSON.wrap(flag).unWrap()

        case "featureFlagManager#trackInteraction":
            let arg = try call.requireStringArg()
            guard let jsonData = arg.data(using: .utf8),
                  let featureFlagProxy = try? JSONDecoder().decode(FeatureFlagProxy.self, from: jsonData) else {
                throw AirshipErrors.error("Call requires a json string that's decodable to FeatureFlagProxy")
            }

            try AirshipProxy.shared.featureFlagManager.trackInteraction(flag: featureFlagProxy)

            return nil

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


class AirshipEventStreamHandler: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private var eventType: AirshipProxyEventType

    var onListenerAdded: () -> Void

    internal init(
        eventSink: FlutterEventSink? = nil,
        eventType: AirshipProxyEventType,
        onListenerAdded: @escaping () -> Void
    ) {
        self.eventSink = eventSink
        self.eventType = eventType
        self.onListenerAdded = onListenerAdded
    }

    func onListen(
        withArguments arguments: Any?,
        eventSink events: @escaping FlutterEventSink
    ) -> FlutterError? {
        self.eventSink = events
        onListenerAdded()
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {

        self.eventSink = nil
        return nil
    }

    
    func notify(_ event: Any) -> Bool {
        if let sink = self.eventSink {
            DispatchQueue.main.async {
                sink(event)
            }
            return true
        }
        return false
    }
}

class AirshipEventStream: NSObject {
    private let eventType: AirshipProxyEventType
    private let name: String
    private let lock = AirshipLock()
    private var handlers: [AirshipEventStreamHandler] = []

    init(_ eventType: AirshipProxyEventType, name: String) {
        self.eventType = eventType
        self.name = name
    }

    func register(registrar: FlutterPluginRegistrar) {
        let eventChannel = FlutterEventChannel(
            name: self.name,
            binaryMessenger: registrar.messenger()
        )

        let handler = AirshipEventStreamHandler(eventType: eventType) {
            Task { [weak self] in
                await self?.processPendingEvents()
            }
        }

        eventChannel.setStreamHandler(handler)

        lock.sync {
            handlers.append(handler)
        }
    }

    @MainActor
    func processPendingEvents() async {
        await MainActor.run {
            Task {
                await AirshipProxyEventEmitter.shared.processPendingEvents(
                    type: eventType,
                    handler: { [weak self] event in
                        guard let self = self else { return false }
                        return self.notify(event)
                    }
                )
            }
        }
    }

    func notify(_ event: any AirshipProxyEvent) -> Bool {
        var result = false
        lock.sync {
            for handler in handlers {
                do {
                    if handler.notify(try event.body.unwrapped()) {
                        result = true
                    }
                } catch {
                    AirshipLogger.error("Failed to unwrap event body \(event.body) \(error)")
                }
            }
        }
        return result
    }
}

fileprivate extension Encodable {
    func unwrapped<T>() throws -> T {
        guard let value = try AirshipJSON.wrap(self).unWrap() as? T else {
            throw AirshipErrors.error("Failed to unwrap codable")
        }
        return value
    }
}
