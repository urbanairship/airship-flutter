package com.airship.flutter

import com.urbanairship.AirshipReceiver
import com.urbanairship.util.UAStringUtil

fun AirshipReceiver.NotificationInfo.canonicalNotificationId() : String {
    var id = notificationId.toString()
    if (!UAStringUtil.isEmpty(notificationTag)) {
        id += ":$notificationTag"
    }

    return id
}
