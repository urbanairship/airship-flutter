import Foundation
import AirshipKit

class AirshipPushReceivedEvent : AirshipEvent {
    let body: [AnyHashable : Any]

    init(_ userInfo : [AnyHashable : Any]) {
        self.body = [
            "payload": userInfo,
            "notification": PushUtils.contentPayload(userInfo)
        ]
    }

    var eventType: AirshipEventType {
        get {
            return AirshipEventType.PushReceived
        }
    }

    var data: Any? {
        get {
            return self.body
        }
    }
}
