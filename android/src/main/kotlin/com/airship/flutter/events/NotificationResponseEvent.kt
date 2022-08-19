package com.airship.flutter.events

import com.airship.flutter.eventData
import com.urbanairship.push.NotificationActionButtonInfo
import com.urbanairship.push.NotificationInfo
import com.urbanairship.json.JsonMap
import com.urbanairship.json.JsonValue

class NotificationResponseEvent(notificationInfo: NotificationInfo,
                                actionButtonInfo: NotificationActionButtonInfo? = null) : Event {

    override val eventType: EventType = EventType.NOTIFICATION_RESPONSE

    override val eventBody: JsonValue? by lazy {
        JsonMap.newBuilder()
                .put("notification", notificationInfo.eventData())
                .put("payload", notificationInfo.message.toJsonValue())
                .let {
                    if (actionButtonInfo != null) {
                        it.put("action_id", actionButtonInfo.buttonId)
                                .put("is_foreground", actionButtonInfo.isForeground)
                    } else {
                        it.put("is_foreground", true)
                    }
                }
                .build()
                .toJsonValue()
    }


}