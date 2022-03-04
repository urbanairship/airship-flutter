import Foundation

class AirshipShowPreferenceCenterEvent : AirshipEvent {

    let preferenceCenterId: String

    init(_ preferenceCenterId : String) {
        self.preferenceCenterId = preferenceCenterId;
    }
    
    var eventType: AirshipEventType {
        get {
            return AirshipEventType.ShowPreferenceCenter
        }
    }

    var data: Any? {
        get {
            return preferenceCenterId
        }
    }
}
