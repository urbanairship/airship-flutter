package com.airship.flutter.events

class ChannelUpdatedEvent(channelId : String, registrationToken : String?)
    : ChannelRegistrationEvent(channelId, registrationToken) {

    override val eventType: EventType = EventType.CHANNEL_UPDATED;
}