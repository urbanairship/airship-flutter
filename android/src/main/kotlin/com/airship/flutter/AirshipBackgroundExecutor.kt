package com.airship.flutter

import android.content.Context
import android.content.SharedPreferences
import android.os.Handler
import androidx.core.content.edit
import com.urbanairship.json.JsonValue
import com.urbanairship.push.NotificationInfo
import com.urbanairship.push.PushMessage
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterShellArgs
import io.flutter.embedding.engine.dart.DartExecutor.DartCallback
import io.flutter.embedding.engine.loader.FlutterLoader
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.view.FlutterCallbackInformation.lookupCallbackInformation
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import java.util.Collections
import java.util.concurrent.atomic.AtomicBoolean

class AirshipBackgroundExecutor(
    private val appContext: Context,
    private val sharedPrefs: SharedPreferences = appContext.getAirshipSharedPrefs()
) : MethodCallHandler {
    private val isIsolateStarted: AtomicBoolean = AtomicBoolean(false)

    private var methodChannel: MethodChannel? = null
    private var flutterEngine: FlutterEngine? = null

    private val mainHandler by lazy {
        Handler(appContext.mainLooper)
    }

    private val messageCallback: Long
        get() = sharedPrefs.getLong(MESSAGE_CALLBACK, 0)

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) =
        when (call.method) {
            "backgroundIsolateStarted" -> {
                result.success(true)
                onIsolateStarted()
            }
            else -> result.notImplemented()
        }

    fun startIsolate(callback: Long, args: FlutterShellArgs?) {
        if (flutterEngine != null) return

        val loader = FlutterLoader()
        mainHandler.post {
            loader.startInitialization(appContext)
            loader.ensureInitializationCompleteAsync(appContext, null, mainHandler) {
                if (!isIsolateStarted.get()) {
                    val engine = FlutterEngine(appContext, args?.toArray())
                        .also { flutterEngine = it }

                    methodChannel =
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
    }

    private fun onIsolateStarted() {
        isIsolateStarted.set(true)

        // Notify the background message callback with any messages that were queued up while the
        // isolate was starting.
        synchronized(messageQueue) {
            for ((message, notificationInfo) in messageQueue) {
                handleBackgroundMessage(appContext, message, notificationInfo)
            }
            messageQueue.clear()
        }
    }

    val isReady: Boolean
        get() = isIsolateStarted.get()

    @OptIn(ExperimentalCoroutinesApi::class)
    private fun executeDartCallbackInBackgroundIsolate(
        pushMessage: PushMessage,
        notificationInfo: NotificationInfo? = null
    ) = callbackFlow<Unit> {
        if (flutterEngine == null) {
            trySend(Unit)
            channel.close()
            return@callbackFlow
        }

        val result: MethodChannel.Result = object : MethodChannel.Result {
            override fun success(result: Any?) {
                trySend(Unit)
                channel.close()
            }

            override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {
                trySend(Unit)
                channel.close()
            }

            override fun notImplemented() {
                trySend(Unit)
                channel.close()
            }
        }

        val eventData = notificationInfo?.eventData()?.toJsonValue() ?: JsonValue.NULL
        val args = mapOf(
            "messageCallback" to messageCallback,
            "payload" to pushMessage.toJsonValue().toString(),
            "notification" to eventData.toString()
        )

        mainHandler.post {
            methodChannel?.invokeMethod("onBackgroundMessage", args, result) ?: run {
                trySend(Unit)
                channel.close()
            }
        }

        awaitClose()
    }

    companion object {
        private const val TAG = "airship"
        private const val BACKGROUND_CHANNEL = "com.airship.flutter/airship_background"
        private const val ISOLATE_CALLBACK = "isolate_callback"
        private const val MESSAGE_CALLBACK = "message_callback"

        private val messageQueue =
            Collections.synchronizedList(mutableListOf<Pair<PushMessage, NotificationInfo?>>())

        @Volatile
        internal var instance: AirshipBackgroundExecutor? = null
            private set

        internal fun startIsolate(context: Context, shellArgs: FlutterShellArgs? = null) {
            val callback = context.getAirshipSharedPrefs().getLong(ISOLATE_CALLBACK, 0)
            if (instance?.isReady == true || callback == 0L) return

            startIsolate(context, callback, shellArgs)
        }

        private fun startIsolate(
            context: Context,
            callbackHandle: Long,
            shellArgs: FlutterShellArgs?
        ) {
            if (instance != null) return
            synchronized(this) {
                if (instance != null) return
                instance = AirshipBackgroundExecutor(context).apply {
                    startIsolate(callbackHandle, shellArgs)
                }
            }
        }

        internal fun setCallbacks(context: Context, isolateCallback: Long, messageCallback: Long) {
            context.getAirshipSharedPrefs().edit {
                putLong(ISOLATE_CALLBACK, isolateCallback)
                putLong(MESSAGE_CALLBACK, messageCallback)
            }
        }

        internal fun handleBackgroundMessage(
            context: Context,
            pushMessage: PushMessage,
            notificationInfo: NotificationInfo? = null
        ) {
            if (!hasMessageCallback(context)) return

            val executor = instance
            if (executor?.isReady == true) {
                // Send the message to the registered handler callback via the background isolate.
                GlobalScope.launch {
                    executor.executeDartCallbackInBackgroundIsolate(pushMessage, notificationInfo).first()
                }
            } else {
                // Isolate not ready. Queue the message for later.
                messageQueue.add(pushMessage to notificationInfo)
            }
        }

        private fun hasMessageCallback(context: Context): Boolean =
            context.getAirshipSharedPrefs().getLong(MESSAGE_CALLBACK, 0) != 0L
    }
}
