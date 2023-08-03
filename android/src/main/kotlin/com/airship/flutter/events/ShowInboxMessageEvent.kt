package com.airship.flutter.events

import com.urbanairship.json.JsonValue

class ShowInboxMessageEvent(messageId : String) : Event {

    override val eventType: EventType = EventType.SHOW_INBOX_MESSAGE

    override val eventBody: JsonValue? by lazy {
        JsonValue.wrap(messageId)
    }
}