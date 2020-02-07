import Foundation

class AirshipWebviewClosedEvent : AirshipEvent {

    var eventType: AirshipEventType {
        get {
            return AirshipEventType.WebviewClosed
        }
    }

    var data: Any? {
        get {
            return nil
        }
    }
}
