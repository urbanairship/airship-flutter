package com.airship.flutter

import android.os.Build
import android.os.Bundle
import android.service.notification.StatusBarNotification
import androidx.annotation.RequiresApi
import com.urbanairship.analytics.CustomEvent
import com.urbanairship.json.JsonMap
import com.urbanairship.push.NotificationInfo
import com.urbanairship.push.PushMessage
import com.urbanairship.util.UAStringUtil

fun NotificationInfo.canonicalNotificationId() : String {
    var id = notificationId.toString()
    if (!UAStringUtil.isEmpty(notificationTag)) {
        id += ":$notificationTag"
    }

    return id
}

fun NotificationInfo.eventData() : JsonMap {
    return JsonMap.newBuilder()
            .putOpt("alert", message.alert)
            .putOpt("title", message.title)
            .putOpt("extras", message.toJsonValue())
            .putOpt("notification_id", canonicalNotificationId())
            .build()
}

fun CustomEvent.Builder.parseProperties(map:HashMap<String, Any>) {
    for ((key, value) in map) {
        if (value is Int) {
            this.addProperty(key, value)
            continue
        }

        if (value is Boolean) {
            this.addProperty(key, value)
            continue
        }

        if (value is String) {
            this.addProperty(key, value)
            continue
        }

        if (value is Collection<*>) {
            value.filterIsInstance<String>().let {
                this.addProperty(key, it)
            }
            continue
        }
    }
}

@RequiresApi(Build.VERSION_CODES.KITKAT)
fun StatusBarNotification.pushMessage(): PushMessage {
    val extras = this.notification.extras ?: return PushMessage(Bundle())

    val pushBundle = extras.getBundle(PUSH_MESSAGE_BUNDLE_EXTRA)
    return if (pushBundle == null) {
        PushMessage(Bundle())
    } else {
        PushMessage(pushBundle)
    }

}