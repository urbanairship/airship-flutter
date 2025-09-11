package com.airship.flutter

import android.content.Context
import android.content.Context.MODE_PRIVATE
import android.util.Log
import com.airship.flutter.AirshipPlugin.Companion.AIRSHIP_SHARED_PREFS
import com.urbanairship.app.GlobalActivityMonitor
import com.urbanairship.json.JsonSerializable
import com.urbanairship.json.JsonValue
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch
import org.json.JSONObject

internal fun MethodChannel.Result.resolve(scope: CoroutineScope, call: MethodCall, function: suspend () -> Any?) {
    scope.launch {
        try {
            when (val result = function()) {
                is Unit -> {
                    this@resolve.successSafe(null)
                }
                is JsonSerializable -> {
                    this@resolve.successSafe(result.toJsonValue().unwrap())
                }
                is java.util.LinkedHashSet<*> -> {
                    this@resolve.successSafe(result.toList())
                }
                else -> {
                    this@resolve.successSafe(JsonValue.wrapOpt(result).unwrap())
                }
            }
        } catch (e: Exception) {
            this@resolve.errorSafe(call, e)
        }
    }
}
private fun MethodChannel.Result.successSafe(result: Any?) {
    try {
        this.success(result)
    } catch (e: Exception) {
        Log.e("AirshipPlugin", "Failed to send success result", e)
    }
}

private fun MethodChannel.Result.errorSafe(call: MethodCall, exception: Exception) {
    try {
        this.error("AIRSHIP_ERROR", exception.message, "Method: ${call.method}")
    } catch (e: Exception) {
        Log.e("AirshipPlugin", "Failed to send error result", e)
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

fun String.toMap(): Map<String, Any?> {
    val jsonObject = JSONObject(this)
    val map = mutableMapOf<String, Any?>()

    jsonObject.keys().forEach { key ->
        val value = jsonObject.get(key)
        map[key] = value
    }

    return map
}

internal fun Context.getAirshipSharedPrefs() =
    getSharedPreferences(AIRSHIP_SHARED_PREFS, MODE_PRIVATE)

internal fun Context.isAppInForeground(): Boolean {
    return GlobalActivityMonitor.shared(this).isAppForegrounded
}

