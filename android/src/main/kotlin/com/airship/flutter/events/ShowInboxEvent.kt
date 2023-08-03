package com.airship.flutter.events

import com.urbanairship.json.JsonValue

class ShowInboxEvent : Event {

    override val eventType: EventType = EventType.SHOW_INBOX

    override val eventBody: JsonValue? = null
}