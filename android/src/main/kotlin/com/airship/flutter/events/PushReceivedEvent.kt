package com.airship.flutter.events

import com.airship.flutter.eventData
import com.urbanairship.AirshipReceiver
import com.urbanairship.json.JsonMap
import com.urbanairship.json.JsonValue
import com.urbanairship.push.PushMessage


open class PushReceivedEvent(pushMessage: PushMessage, notificationInfo: AirshipReceiver.NotificationInfo? = null) : Event {
    override val eventType: EventType = EventType.PUSH_RECEIVED

    override val eventBody: JsonValue? by lazy {
        JsonMap.newBuilder()
                .put("payload", pushMessage.toJsonValue())
                .apply {
                    if (notificationInfo != null) {
                        this.put("notification", notificationInfo.eventData())
                    }
                }
                .build()
                .toJsonValue()
    }

}