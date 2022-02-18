package com.airship.flutter.events

import com.urbanairship.json.JsonValue

class ShowPreferenceCenterEvent(preferenceCenterId : String) : Event {

    override val eventType: EventType = EventType.SHOW_PREFERENCE_CENTER

    override val eventBody: JsonValue? by lazy {
        JsonValue.wrap(preferenceCenterId)
    }
}
