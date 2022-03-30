package com.airship.flutter

import android.content.Context
import android.content.SharedPreferences
import android.os.Handler
import android.util.Log
import androidx.core.content.edit
import com.airship.flutter.AirshipBackgroundExecutor.Companion.BackgroundMessageResult.*
import com.urbanairship.push.PushMessage
import com.urbanairship.push.notifications.NotificationArguments
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterShellArgs
import io.flutter.embedding.engine.dart.DartExecutor.DartCallback
import io.flutter.embedding.engine.loader.FlutterLoader
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.view.FlutterCallbackInformation.lookupCallbackInformation
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.runBlocking
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
                onIsolateStarted()
                result.success(true)
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
    }

    val isReady: Boolean
        get() = isIsolateStarted.get()

    @OptIn(ExperimentalCoroutinesApi::class)
    private fun executeDartCallbackInBackgroundIsolate(
        pushMessage: PushMessage
    ) = callbackFlow<Boolean> {
        if (flutterEngine == null) {
            trySend(false)
            channel.close()
            return@callbackFlow
        }

        val result: MethodChannel.Result = object : MethodChannel.Result {
            override fun success(result: Any?) {
                trySend(result as? Boolean == true)
                channel.close()
            }

            override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {
                trySend(false)
                channel.close()
            }

            override fun notImplemented() {
                trySend(false)
                channel.close()
            }
        }

        val args = mapOf(
            "messageCallback" to messageCallback,
            "payload" to pushMessage.toJsonValue().toString()
        )

        mainHandler.post {
            methodChannel?.invokeMethod("onBackgroundMessage", args, result) ?: run {
                Log.w(TAG, "Background method channel is null!")
                trySend(false)
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

        internal enum class BackgroundMessageResult {
            HANDLED,
            NOT_HANDLED,
            QUEUED
        }

        internal fun handleBackgroundMessage(
            context: Context,
            arguments: NotificationArguments
        ): BackgroundMessageResult {
            if (!hasMessageCallback(context)) {
                return NOT_HANDLED
            }
            val executor = instance
            return if (executor?.isReady == true) {
                // Send the message to the registered handler callback via the background isolate.
                val result = runBlocking(Dispatchers.Main) {
                    executor.executeDartCallbackInBackgroundIsolate(arguments.message).first()
                }

                if (result) HANDLED else NOT_HANDLED
            } else {
                // Isolate not ready. Queue the message for later.
                QUEUED
            }
        }

        private fun hasMessageCallback(context: Context): Boolean =
            context.getAirshipSharedPrefs().getLong(MESSAGE_CALLBACK, 0) != 0L

    }
}
