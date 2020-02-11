package com.airship.flutter.events

import com.urbanairship.json.JsonValue

class WebviewClosedEvent : Event {

    override val eventType: EventType = EventType.WEBVIEW_CLOSED

    override val eventBody: JsonValue? = null
}



