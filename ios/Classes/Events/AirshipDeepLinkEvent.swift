import Foundation

class AirshipDeepLinkEvent : AirshipEvent {

    let deepLink: String

    init(_ deepLink : String) {
        self.deepLink = deepLink;
    }

    var eventType: AirshipEventType {
        get {
            return AirshipEventType.DeepLink
        }
    }

    var data: Any? {
        get {
            return deepLink
        }
    }
}
