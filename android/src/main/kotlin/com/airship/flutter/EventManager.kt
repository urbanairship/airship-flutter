package com.airship.flutter

import com.urbanairship.json.JsonMap
import com.urbanairship.json.JsonSerializable
import io.flutter.plugin.common.EventChannel

enum class EventType {
    PUSH_RECEIVED, CHANNEL_CREATED, CHANNEL_UPDATED, INBOX_UPDATED, SHOW_INBOX
}

class EventManager : EventChannel.StreamHandler {

    companion object {
        val shared = EventManager()
    }

    private var eventSink: EventChannel.EventSink? = null
    private val pendingEvents = mutableListOf<PendingEvent>()

    fun notifyEvent(type: EventType, data: JsonSerializable?) {
        var sink = eventSink
        if (sink != null) {
            sink.success(JsonMap.newBuilder()
                    .put("event_type", type.name)
                    .putOpt("data", data)
                    .build().toString())

        } else {
            pendingEvents.add(PendingEvent(type, data))
        }
    }

    override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink?) {
        this.eventSink = eventSink
        pendingEvents.forEach {
            notifyEvent(it.eventType, it.data)
        }
        pendingEvents.clear()
    }

    override fun onCancel(p0: Any?) {
        this.eventSink = null
    }
}

internal data class PendingEvent(val eventType: EventType, val data : JsonSerializable?)

