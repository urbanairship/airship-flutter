package com.airship.flutter.events

import com.urbanairship.json.JsonMap
import com.urbanairship.json.JsonValue

open class ChannelRegistrationEvent(private val channelId: String, private val registrationToken: String?) : Event {

    override val eventType: EventType = EventType.CHANNEL_REGISTRATION

    override val eventBody: JsonValue? by lazy {
        JsonMap.newBuilder()
                .put("channel_id", channelId)
                .putOpt("registration_token", registrationToken)
                .build()
                .toJsonValue() as JsonValue
    }

}