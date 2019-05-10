import Foundation

class AirshipShowInboxEvent : AirshipEvent {

    var eventType: AirshipEventType {
        get {
            return AirshipEventType.ShowInbox
        }
    }

    var data: Any? {
        get {
            return nil
        }
    }
}
