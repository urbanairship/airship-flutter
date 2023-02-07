package com.airship.flutter

import com.urbanairship.util.UAStringUtil
import com.urbanairship.push.PushMessage
import org.json.JSONException

class Utils {

    companion object {
        val shared = Utils()
    }

    @Throws(JSONException::class)
    fun notificationObject(message: PushMessage, notificationTag: String, notificationId: String?): Map<String, Any?> {
        val notification = mutableMapOf<String, Any?>()
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
            notification["alert"] = message.alert
        }
        if (message.title != null) {
            notification["title"] = message.title
        }
        if (message.summary != null) {
            notification["subtitle"] = message.summary
        }
        notification["extras"] = extras;

        if (notificationId != null) {
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
