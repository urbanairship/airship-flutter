import Foundation

class AirshipChannelUpdatedEvent : AirshipChannelCreatedEvent {
    override var eventType: AirshipEventType {
        get {
            return AirshipEventType.ChannelUpdated
        }
    }
}
