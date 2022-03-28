package com.airship.flutter

import android.app.ActivityManager
import android.app.ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND
import android.app.KeyguardManager
import android.content.Context
import android.content.Context.ACTIVITY_SERVICE
import android.content.Context.KEYGUARD_SERVICE
import android.content.Context.MODE_PRIVATE
import android.os.Build
import android.os.Bundle
import android.service.notification.StatusBarNotification
import androidx.annotation.RequiresApi
import com.airship.flutter.AirshipPlugin.Companion.AIRSHIP_SHARED_PREFS
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

internal fun Context.getAirshipSharedPrefs() =
    getSharedPreferences(AIRSHIP_SHARED_PREFS, MODE_PRIVATE)

internal fun Context.isAppInForeground(): Boolean {
    val keyguardManager = getSystemService(KEYGUARD_SERVICE) as? KeyguardManager ?: return false
    if (keyguardManager.isKeyguardLocked) return false

    val activityManager = getSystemService(ACTIVITY_SERVICE) as? ActivityManager ?: return false
    val processes = activityManager.runningAppProcesses ?: return false

    val pkgName = packageName
    return processes.any { it.importance == IMPORTANCE_FOREGROUND && it.processName == pkgName }
}
