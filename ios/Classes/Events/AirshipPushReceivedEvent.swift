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
            let payload = ["payload": self.payload]
            return payload
        }
    }
}
