import Foundation

class AirshipWebviewLoadFinishedEvent : AirshipEvent {

    var eventType: AirshipEventType {
        get {
            return AirshipEventType.WebviewLoadFinished
        }
    }

    var data: Any? {
        get {
            return nil
        }
    }
}
