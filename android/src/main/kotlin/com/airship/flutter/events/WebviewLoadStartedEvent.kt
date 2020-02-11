package com.airship.flutter.events

import com.urbanairship.json.JsonValue

class WebviewLoadStartedEvent : Event {

    override val eventType: EventType = EventType.WEBVIEW_LOAD_STARTED

    override val eventBody: JsonValue? = null
}
