package com.airship.flutter.events

import com.airship.flutter.canonicalNotificationId
import com.urbanairship.AirshipReceiver
import com.urbanairship.json.JsonMap
import com.urbanairship.json.JsonValue
import com.urbanairship.util.UAStringUtil


class NotificationResponseEvent(notificationInfo: AirshipReceiver.NotificationInfo,
                                actionButtonInfo: AirshipReceiver.ActionButtonInfo? = null) : Event {

    override val eventType: EventType = EventType.NOTIFICATION_RESPONSE

    override val eventBody: JsonValue? by lazy {
        JsonMap.newBuilder()
                .put("notification_id", notificationInfo.canonicalNotificationId())
                .put("notification_payload", notificationInfo.message.toJsonValue())
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