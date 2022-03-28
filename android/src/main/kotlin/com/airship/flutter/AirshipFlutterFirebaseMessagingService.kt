package com.airship.flutter

import android.content.Context
import android.os.Handler
import android.util.Log
import com.google.firebase.messaging.RemoteMessage
import com.urbanairship.push.fcm.AirshipFirebaseIntegration
import com.urbanairship.push.fcm.AirshipFirebaseMessagingService
import io.flutter.embedding.engine.FlutterShellArgs
import java.util.concurrent.ConcurrentLinkedQueue
import java.util.concurrent.CountDownLatch

class AirshipFlutterFirebaseMessagingService : AirshipFirebaseMessagingService() {

    private val mainHandler by lazy {
        Handler(mainLooper)
    }

    private val isMessageCallbackSet: Boolean
        get() = AirshipBackgroundExecutor.hasMessageCallback(applicationContext)

    override fun onMessageReceived(message: RemoteMessage) =
        if (applicationContext.isAppInForeground() || !isMessageCallbackSet) {
            super.onMessageReceived(message)
        } else {
            handleBackgroundMessage(message)
        }

    // Avoid class warning about not implementing onNewToken by calling through to super
    @Suppress("RedundantOverride")
    override fun onNewToken(token: String) = super.onNewToken(token)

    override fun onCreate() {
        super.onCreate()

        if (backgroundExecutor == null) {
            backgroundExecutor = AirshipBackgroundExecutor(applicationContext).apply {
                startIsolate()
            }
        }
    }

    private fun handleBackgroundMessage(message: RemoteMessage) {
        if (!AirshipBackgroundExecutor.hasMessageCallback(applicationContext)) return

        val executor = backgroundExecutor
        if (executor?.isReady == true) {
            val latch = CountDownLatch(1)
            // Send the message to the registered handler callback via the background isolate.
            mainHandler.post {
                executor.executeDartCallbackInBackgroundIsolate(message, latch) {
                    super.onMessageReceived(message)
                }
            }
        } else {
            // If the background isolate is not ready, queue the message for later processing.
            messageQueue.offer(message)
        }
    }

    companion object {
        private const val TAG = "airship"

        private var backgroundExecutor: AirshipBackgroundExecutor? = null

        private val messageQueue = ConcurrentLinkedQueue<RemoteMessage>()

        internal fun onIsolateStarted(context: Context) {
            Log.d(TAG, "Airship flutter background service started!")

            backgroundExecutor?.run {
                while(true) {
                    val message = messageQueue.poll() ?: break
                    executeDartCallbackInBackgroundIsolate(message, null) {
                        // Background message unhandled; process it normally.
                        AirshipFirebaseIntegration.processMessageSync(context, message)
                    }
                }
            }
        }

        internal fun startIsolate(
            context: Context,
            callbackHandle: Long,
            shellArgs: FlutterShellArgs?
        ) {
            if (backgroundExecutor != null) return
            backgroundExecutor = AirshipBackgroundExecutor(context).apply {
                startIsolate(callbackHandle, shellArgs)
            }
        }

        internal fun setCallbackDispatcher(context: Context, callbackHandle: Long) =
            AirshipBackgroundExecutor.setIsolateCallback(context, callbackHandle)

        internal fun setUserCallbackHandle(context: Context, callbackHandle: Long) =
            AirshipBackgroundExecutor.setMessageCallback(context, callbackHandle)
    }
}
