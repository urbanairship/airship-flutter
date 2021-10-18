import Foundation
import AirshipKit

class AirshipNotificationResponseEvent : AirshipPushReceivedEvent {
    let notificationResponse: UNNotificationResponse

    init(_ notificationResponse : UNNotificationResponse) {
        self.notificationResponse = notificationResponse
        super.init(notificationResponse.notification.request.content.userInfo)
    }

    override var eventType: AirshipEventType {
        get {
            return AirshipEventType.NotificationResponse
        }
    }

    override var data: Any? {
        get {
            var payload = super.data as! [String: Any]

            if (self.notificationResponse.actionIdentifier == UNNotificationDefaultActionIdentifier) {
                payload["is_foreground"] = true
            } else {
                if let action = self.findAction(notificationResponse) {
                    payload["is_foreground"] = action.options.contains(.foreground)
                } else {
                    payload["is_foreground"] = true
                }
                payload["action_id"] = self.notificationResponse.actionIdentifier
            }
            return payload
        }
    }

    func findAction(_ notificationResponse: UNNotificationResponse) -> UNNotificationAction? {
        return Airship.push.combinedCategories.first(where: { (category) -> Bool in
            return category.identifier == notificationResponse.notification.request.content.categoryIdentifier
        })?.actions.first(where: { (action) -> Bool in
            return action.identifier == notificationResponse.actionIdentifier
        })
    }
}
