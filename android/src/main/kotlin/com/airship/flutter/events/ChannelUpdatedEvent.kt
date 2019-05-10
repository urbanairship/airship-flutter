package com.airship.flutter.events

class ChannelUpdatedEvent(channelId : String, registrationToken : String?)
    : ChannelCreatedEvent(channelId, registrationToken) {

    override val eventType: EventType = EventType.CHANNEL_UPDATED;
}