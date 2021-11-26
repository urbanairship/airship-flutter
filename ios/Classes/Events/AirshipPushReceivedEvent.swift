import Foundation
import AirshipKit

class AirshipPushReceivedEvent : AirshipEvent {
    let payload: [AnyHashable : Any]

    init(_ userInfo : [AnyHashable : Any]) {
        self.payload = userInfo
    }

    var eventType: AirshipEventType {
        get {
            return AirshipEventType.PushReceived
        }
    }

    var data: Any? {
        get {
            var payload = ["payload": self.payload]
            var notificationPayload : [String:Any] = [:]
            
            if let aps = self.payload["aps"] as? [String : Any] {
                if let alert = aps["alert"] as? [String : Any] {
                    if let body = alert["body"] {
                        notificationPayload["alert"] = body
                    }
                    if let title = alert["title"] {
                        notificationPayload["title"] = title
                    }
                } else if let alert = aps["alert"] as? String {
                    notificationPayload["alert"] = alert
                }
               
                var extras = self.payload
                extras["_"] = nil
                extras["aps"] = nil
                notificationPayload["extras"] = extras
                payload["notification"] = notificationPayload
            }
             
            return payload
        }
    }
}
