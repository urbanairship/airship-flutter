package com.airship.flutter.events

import com.urbanairship.json.JsonValue

class WebviewLoadFinishedEvent : Event {

    override val eventType: EventType = EventType.WEBVIEW_LOAD_FINISHED

    override val eventBody: JsonValue? = null
}


