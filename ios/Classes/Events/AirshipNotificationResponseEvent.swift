import Foundation
import AirshipKit

class AirshipNotificationResponseEvent : AirshipPushReceivedEvent {
    let notificationResponse: UANotificationResponse

    init(_ notificationResponse : UANotificationResponse) {
        self.notificationResponse = notificationResponse
        super.init(notificationResponse.notificationContent)
    }

    override var eventType: AirshipEventType {
        get {
            return AirshipEventType.NotificationResponse
        }
    }

    override var data: Any? {
        get {
            var payload = super.data as! [String: Any]

            if (self.notificationResponse.actionIdentifier == UANotificationDefaultActionIdentifier) {
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

    func findAction(_ notificationResponse: UANotificationResponse) -> UANotificationAction? {
        return UAirship.push()?.combinedCategories.first(where: { (category) -> Bool in
            return category.identifier == notificationResponse.notificationContent.categoryIdentifier
        })?.actions.first(where: { (action) -> Bool in
            return action.identifier == notificationResponse.actionIdentifier
        })
    }
}
