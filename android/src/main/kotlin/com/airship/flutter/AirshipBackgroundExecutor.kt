package com.airship.flutter

import android.content.Context
import android.content.SharedPreferences
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.core.content.edit
import com.google.firebase.messaging.RemoteMessage
import com.urbanairship.push.fcm.AirshipFirebaseIntegration
import com.urbanairship.push.fcm.AirshipFirebaseMessagingService
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterShellArgs
import io.flutter.embedding.engine.dart.DartExecutor.DartCallback
import io.flutter.embedding.engine.loader.FlutterLoader
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.view.FlutterCallbackInformation.lookupCallbackInformation
import java.util.concurrent.CountDownLatch
import java.util.concurrent.atomic.AtomicBoolean

class AirshipBackgroundExecutor(
    private val appContext: Context,
    private val sharedPrefs: SharedPreferences = appContext.getAirshipSharedPrefs()
) : MethodCallHandler {
    private val isIsolateStarted: AtomicBoolean = AtomicBoolean(false)

    private var channel: MethodChannel? = null
    private var flutterEngine: FlutterEngine? = null

    private val messageCallback: Long
        get() = sharedPrefs.getLong(MESSAGE_CALLBACK, 0)

    private val isolateCallback: Long
        get() = sharedPrefs.getLong(ISOLATE_CALLBACK, 0L)

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) =
        when (call.method) {
            "backgroundIsolateStarted" -> {
                onIsolateStarted()
                result.success(true)
            }

            else -> result.notImplemented()
        }

    fun startIsolate() {
        val callback = isolateCallback
        if (isIsolateStarted.get() || callback == 0L) return

        startIsolate(callback, null)
    }

    fun startIsolate(callback: Long, args: FlutterShellArgs?) {
        if (flutterEngine != null) return

        val loader = FlutterLoader()
        val handler = Handler(Looper.getMainLooper())

        val runnable = Runnable {
            loader.startInitialization(appContext)
            loader.ensureInitializationCompleteAsync(appContext, null, handler) {
                if (!isIsolateStarted.get()) {
                    Log.i(
                        TAG,
                        "Creating background FlutterEngine instance, with args: ${
                            args?.toArray().contentToString()
                        }"
                    )

                    val engine = FlutterEngine(appContext, args?.toArray())
                         .also { flutterEngine = it }

                    channel =
                        MethodChannel(engine.dartExecutor, BACKGROUND_CHANNEL).apply {
                            setMethodCallHandler(this@AirshipBackgroundExecutor)
                        }

                    val callbackInfo = lookupCallbackInformation(callback)
                    engine.dartExecutor.executeDartCallback(
                        DartCallback(appContext.assets, loader.findAppBundlePath(), callbackInfo)
                    )
                }
            }
        }

        handler.post(runnable)
    }

    private fun onIsolateStarted() {
        isIsolateStarted.set(true)
        AirshipFlutterFirebaseMessagingService.onIsolateStarted(appContext)
    }

    val isReady: Boolean
        get() = isIsolateStarted.get()

    fun executeDartCallbackInBackgroundIsolate(remoteMessage: RemoteMessage, latch: CountDownLatch?, onUnhandled: (RemoteMessage) -> Unit) {
        if (flutterEngine == null) {
            Log.i(TAG, "A background message could not be handled in Dart as no onBackgroundMessage handler has been registered.")
            onUnhandled.invoke(remoteMessage)
            return
        }

        val args = mapOf(
            "messageCallback" to messageCallback,
            "message" to remoteMessage.data
        )

        val result: MethodChannel.Result? = latch?.let {
            object : MethodChannel.Result {
                override fun success(result: Any?) {
                    if (result as? Boolean == false) {
                        onUnhandled.invoke(remoteMessage)
                    }
                    it.countDown()
                }

                override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) =
                    it.countDown()

                override fun notImplemented() = it.countDown()
            }
        }

        channel?.invokeMethod("onBackgroundMessage", args, result)
            ?: Log.e(TAG, "Background channel is null!")
    }

    companion object {
        private const val TAG = "airship"
        internal const val BACKGROUND_CHANNEL = "com.airship.flutter/airship_background"
        internal const val ISOLATE_CALLBACK = "isolate_callback"
        internal const val MESSAGE_CALLBACK = "message_callback"

        fun setIsolateCallback(context: Context, callbackHandle: Long) =
            context.getAirshipSharedPrefs().edit { putLong(ISOLATE_CALLBACK, callbackHandle) }

        fun hasMessageCallback(context: Context): Boolean =
            context.getAirshipSharedPrefs().getLong(ISOLATE_CALLBACK, 0) != 0L

        fun setMessageCallback(context: Context, callbackHandle: Long) =
            context.getAirshipSharedPrefs().edit { putLong(MESSAGE_CALLBACK, callbackHandle) }
    }
}
