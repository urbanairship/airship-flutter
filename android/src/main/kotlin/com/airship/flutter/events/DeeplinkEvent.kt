package com.airship.flutter.events

import com.urbanairship.json.JsonValue

class DeepLinkEvent(deepLink : String) : Event {

    override val eventType: EventType = EventType.DEEP_LINK

    override val eventBody: JsonValue? by lazy {
        JsonValue.wrap(deepLink)
    }
}