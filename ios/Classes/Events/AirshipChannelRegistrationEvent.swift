import Foundation

class AirshipChannelRegistrationEvent : AirshipEvent {

    let channelId: String
    let registrationToken: String?

    init(_ channelId : String, registrationToken: String?) {
        self.channelId = channelId;
        self.registrationToken = registrationToken;
    }

    var eventType: AirshipEventType {
        get {
            return AirshipEventType.ChannelRegistration
        }
    }

    var data: Any? {
        get {
            var payload = ["channel_id": channelId]
            if (registrationToken != nil) {
                payload["registration_token"]  = registrationToken
            }
            return payload
        }
    }
}
