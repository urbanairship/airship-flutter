package com.airship.flutter.events

import com.airship.flutter.canonicalNotificationId
import com.urbanairship.AirshipReceiver
import com.urbanairship.json.JsonMap
import com.urbanairship.json.JsonValue
import com.urbanairship.push.PushMessage
import com.urbanairship.util.UAStringUtil


class PushReceivedEvent(pushMessage: PushMessage, notificationInfo: AirshipReceiver.NotificationInfo? = null) : Event {
    override val eventType: EventType = EventType.PUSH_RECEIVED

    override val eventBody: JsonValue? by lazy {
        JsonMap.newBuilder()
                .put("push_payload", pushMessage.toJsonValue())
                .putOpt("notification_id", notificationInfo?.canonicalNotificationId())
                .build()
                .toJsonValue()
    }
}