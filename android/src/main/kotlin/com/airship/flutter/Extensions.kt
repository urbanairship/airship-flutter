package com.airship.flutter

import android.content.Context
import android.content.Context.MODE_PRIVATE
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
                    this@resolve.success(null)
                }
                is JsonSerializable -> {
                    this@resolve.success(result.toJsonValue().unwrap())
                }
                is java.util.LinkedHashSet<*> -> {
                    this@resolve.success(result.toList())
                }
                else -> {
                    this@resolve.success(JsonValue.wrapOpt(result).unwrap())
                }
            }
        } catch (e: Exception) {
            this@resolve.error(call, e)
        }
    }
}
internal fun MethodChannel.Result.error(call: MethodCall, exception: java.lang.Exception) {
    this.error("AIRSHIP_ERROR", exception.message, "Method: ${call.method}")
}

//internal fun <T> MethodChannel.Result.resolveDeferred(call: MethodCall, function: ((T?, Exception?) -> Unit) -> Unit) {
//    try {
//        function { result, error ->
//            if (error != null) {
//                this.error(call, error)
//            } else {
//                try {
//                    when (result) {
//                        is Unit -> {
//                            this.success(null)
//                        }
//                        is JsonSerializable -> {
//                            this.success(result.toJsonValue().unwrap())
//                        }
//                        is java.util.LinkedHashSet<*> -> {
//                            this.success(result.toList())
//                        }
//                        else -> {
//                            this.success(result)
//                        }
//                    }
//                } catch (e: Exception) {
//                    this.error(call, e)
//                }
//            }
//        }
//    } catch (e: Exception) {
//        this.error(call, e)
//    }
//}

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

//internal fun <T> MethodChannel.Result.resolvePending(call: MethodCall, function: () -> PendingResult<T>) {
//    resolveDeferred(call) { callback ->
//        function().addResultCallback {
//            callback(it, null)
//        }
//    }
//}

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

