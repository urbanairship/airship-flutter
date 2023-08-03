package com.airship.flutter.events

import com.urbanairship.json.JsonValue

class InboxUpdatedEvent : Event {

    override val eventType: EventType = EventType.INBOX_UPDATED

    override val eventBody: JsonValue? = null
}