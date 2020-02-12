package com.airship.flutter.events

import com.urbanairship.json.JsonValue

enum class EventType {
    PUSH_RECEIVED,
    NOTIFICATION_RESPONSE,
    CHANNEL_REGISTRATION,
    INBOX_UPDATED,
    SHOW_INBOX,
    SHOW_INBOX_MESSAGE,
    DEEP_LINK
}

interface Event {
    val eventBody : JsonValue?
    val eventType: EventType
}