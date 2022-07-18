package com.airship.flutter

import com.airship.flutter.events.Event
import com.airship.flutter.events.EventType
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch

class EventManager {

    companion object {
        val shared = EventManager()
    }

    private val streams: Map<EventType, AirshipEventStream> by lazy {
        EventType.values().map {
            it to AirshipEventStream(it)
        }.toMap()
    }

    fun register(binaryMessenger: BinaryMessenger) {
        streams.values.forEach {
            val eventChannel = EventChannel(binaryMessenger, it.name)
            eventChannel.setStreamHandler(it)
        }
    }

    fun notifyEvent(event: Event) {
        GlobalScope.launch(Dispatchers.Main) {
            streams[event.eventType]?.notifyEvent(event)
        }
    }
}

internal class AirshipEventStream(eventType: EventType) : EventChannel.StreamHandler {

    private var eventSink: EventChannel.EventSink? = null
    private val pendingEvents = mutableListOf<Event>()

    val name: String = "com.airship.flutter/event/${eventType.name}"

    fun notifyEvent(event: Event) {
        val sink = eventSink
        if (sink != null) {
            sink.success(event.eventBody?.toString())
        } else {
            pendingEvents.add(event)
        }
    }


    override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink?) {
        this.eventSink = eventSink

        if (eventSink != null) {
            pendingEvents.forEach(::notifyEvent)
            pendingEvents.clear()
        }
    }

    override fun onCancel(p0: Any?) {
        this.eventSink = null
    }
}
