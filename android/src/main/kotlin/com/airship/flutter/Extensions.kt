package com.airship.flutter

import com.urbanairship.AirshipReceiver
import com.urbanairship.json.JsonMap
import com.urbanairship.util.UAStringUtil

fun AirshipReceiver.NotificationInfo.canonicalNotificationId() : String {
    var id = notificationId.toString()
    if (!UAStringUtil.isEmpty(notificationTag)) {
        id += ":$notificationTag"
    }

    return id
}

fun AirshipReceiver.NotificationInfo.eventData() : JsonMap {
    return JsonMap.newBuilder()
            .putOpt("alert", message.alert)
            .putOpt("title", message.title)
            .putOpt("extras", message.toJsonValue())
            .putOpt("notification_id", canonicalNotificationId())
            .build()
}
