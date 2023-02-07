import Foundation
import AirshipKit

class AirshipNotificationResponseEvent : AirshipEvent {
    
    let data: Any?
    let eventType: AirshipEventType = AirshipEventType.NotificationResponse
    
    init(_ response : UNNotificationResponse) {
        var body: [String: Any] = [
            "payload": response.notification.request.content.userInfo,
            "notification": PushUtils.contentPayload(response.notification.request.content.userInfo),
        ]
        
        if (response.actionIdentifier == UNNotificationDefaultActionIdentifier) {
            body["is_foreground"] = true
        } else {
            if let action = PushUtils.findAction(response) {
                body["is_foreground"] = action.options.contains(.foreground)
            } else {
                body["is_foreground"] = true
            }
            body["action_id"] = response.actionIdentifier
        }
        
        self.data = body
    }
    
    
}
