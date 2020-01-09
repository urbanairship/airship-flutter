import Foundation
import Airship

class AirshipPushReceivedEvent : AirshipEvent {
    let notificationContent: UANotificationContent

    init(_ notificationContent : UANotificationContent) {
        self.notificationContent = notificationContent
    }

    var eventType: AirshipEventType {
        get {
            return AirshipEventType.PushReceived
        }
    }

    var data: Any? {
        get {
            var payload = ["payload": notificationContent.notificationInfo]
            if let notification = notificationContent.notification {
                var notificaitonPayload : [String:Any] = [:]
                notificaitonPayload["alert"] = notificationContent.alertBody
                notificaitonPayload["title"] = notificationContent.alertTitle
                notificaitonPayload["notification_id"] = notification.request.identifier

                var extras = notificationContent.notificationInfo
                extras["_"] = nil
                extras["aps"] = nil
                notificaitonPayload["extras"] = extras
                payload["notification"] = notificaitonPayload
            }

            return payload
        }
    }
}
