import Foundation

class AirshipShowInboxMessageEvent : AirshipEvent {

    let messageId: String

    init(_ messageId : String) {
        self.messageId = messageId;
    }

    var eventType: AirshipEventType {
        get {
            return AirshipEventType.ShowInboxMessage
        }
    }

    var data: Any? {
        get {
            return messageId
        }
    }
}
