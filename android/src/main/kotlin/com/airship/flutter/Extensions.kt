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
import com.urbanairship.PendingResult
import com.urbanairship.json.JsonMap
import com.urbanairship.json.JsonSerializable
import com.urbanairship.json.JsonValue
import com.urbanairship.push.NotificationInfo
import com.urbanairship.push.PushMessage
import com.urbanairship.util.UAStringUtil
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

internal fun MethodChannel.Result.resolveResult(call: MethodCall, function: () -> Any?) {
    resolveDeferred(call) { callback -> callback(function(), null) }
}

internal fun MethodChannel.Result.error(call: MethodCall, exception: java.lang.Exception) {
    this.error("AIRSHIP_ERROR", exception.message, "Method: ${call.method}")
}

internal fun <T> MethodChannel.Result.resolveDeferred(call: MethodCall, function: ((T?, Exception?) -> Unit) -> Unit) {
    try {
        function { result, error ->
            if (error != null) {
                this.error(call, error)
            } else {
                try {
                    when (result) {
                        is Unit -> {
                            this.success(null)
                        }
                        is JsonSerializable -> {
                            this.success(result.toJsonValue().unwrap())
                        }
                        is java.util.LinkedHashSet<*> -> {
                            this.success(result.toList())
                        }
                        else -> {
                            this.success(result)
                        }
                    }
                } catch (e: Exception) {
                    this.error(call, e)
                }
            }
        }
    } catch (e: Exception) {
        this.error(call, e)
    }
}

internal fun MethodCall.jsonArgs(): JsonValue {
    return JsonValue.wrapOpt(arguments)
}

internal fun MethodCall.stringArg(): String {
    return arguments as String
}

internal fun MethodCall.optStringArg(): String? {
    return arguments as? String
}


internal fun MethodCall.booleanArg(): Boolean {
    return arguments as Boolean
}

internal fun MethodCall.longArg(): Long {
    val args: Int = arguments as Int
    return args.toLong()
}

@Suppress("UNCHECKED_CAST")
internal fun MethodCall.stringList(): List<String> {
    return arguments as List<String>
}

internal fun <T> MethodChannel.Result.resolvePending(call: MethodCall, function: () -> PendingResult<T>) {
    resolveDeferred(call) { callback ->
        function().addResultCallback {
            callback(it, null)
        }
    }
}

internal fun JsonSerializable.unwrap(): Any? {
    val json = this.toJsonValue()
    if (json.isNull) {
        return null
    }

    return if (json.isJsonList) {
        json.optList().map { it.unwrap() }
    } else if (json.isJsonMap) {
        json.optMap().map.mapValues { it.value.unwrap() }
    } else {
        json.value
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
        .putOpt("subtitle", message.summary)
        .putOpt("extras", message.toJsonValue())
        .putOpt("notificationId", canonicalNotificationId())
        .build()
}
