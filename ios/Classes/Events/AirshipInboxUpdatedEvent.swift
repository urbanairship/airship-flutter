import Foundation

class AirshipInboxUpdatedEvent : AirshipEvent {

    var eventType: AirshipEventType {
        get {
            return AirshipEventType.InboxUpdated
        }
    }

    var data: Any? {
        get {
            return nil
        }
    }
}
