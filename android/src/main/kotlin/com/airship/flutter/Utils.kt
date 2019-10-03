package com.airship.flutter

import android.os.Build
import android.os.Bundle
import android.service.notification.StatusBarNotification
import androidx.annotation.RequiresApi
import com.urbanairship.util.UAStringUtil
import com.urbanairship.push.PushMessage
import org.json.JSONException

class Utils {

    companion object {
        val shared = Utils()
    }

    @RequiresApi(Build.VERSION_CODES.KITKAT)
    fun messageFromNotification(statusBarNotification: StatusBarNotification): PushMessage {
        val extras = statusBarNotification.notification.extras ?: return PushMessage(Bundle())

        val pushBundle = extras.getBundle(PUSH_MESSAGE_BUNDLE_EXTRA)
        return if (pushBundle == null) {
            PushMessage(Bundle())
        } else {
            PushMessage(pushBundle)
        }
    }

    @Throws(JSONException::class)
    fun notificationObject(message: PushMessage, notificationTag: String, notificationId: String?): Map<String, Any> {
        val notification = mutableMapOf<String, Any>()
        val extras = mutableMapOf<String, String>()
        for (key in message.pushBundle.keySet()) {
            if ("android.support.content.wakelockid" == key) {
                continue
            }
            if ("google.sent_time" == key) {
                extras[key] = java.lang.Long.toString(message.pushBundle.getLong(key))
                continue
            }
            if ("google.ttl" == key) {
                extras[key] = Integer.toString(message.pushBundle.getInt(key))
                continue
            }
            val value = message.pushBundle.getString(key)
            if (value != null) {
                extras[key] = value
            }
        }

        if (message.alert != null) {
            notification["alert"] = message.alert!!
        }
        if (message.title != null) {
            notification["title"] = message.title!!
        }
        if (message.summary != null) {
            notification["subtitle"] = message.summary!!
        }
        notification["extras"] = extras;

        if (notificationId != null) {
            notification["notification_id"] = notificationId
            notification["notificationId"] = getNotificationId(notificationId, notificationTag)
        }
        return notification
    }

    private fun getNotificationId(notificationId: String, notificationTag: String): String {
        var id = notificationId
        if (!UAStringUtil.isEmpty(notificationTag)) {
            id += ":$notificationTag"
        }
        return id
    }
}