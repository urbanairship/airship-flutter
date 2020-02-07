import Foundation

class AirshipWebviewLoadStartedEvent : AirshipEvent {

    var eventType: AirshipEventType {
        get {
            return AirshipEventType.WebviewLoadStarted
        }
    }

    var data: Any? {
        get {
            return nil
        }
    }
}
