package com.airship.flutter

import EventPlugin
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.core.app.JobIntentService
import com.urbanairship.UAirship
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.loader.FlutterLoader
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.view.FlutterCallbackInformation
import io.flutter.view.FlutterMain
import java.util.*
import java.util.concurrent.atomic.AtomicBoolean

class EventService : MethodChannel.MethodCallHandler, JobIntentService() {

    private lateinit var context: Context
    private lateinit var mBackgroundChannel: MethodChannel
    private val queue = ArrayDeque<Any>()

    companion object {
        @JvmStatic
        private val JOB_ID = UUID.randomUUID().mostSignificantBits.toInt()

        @JvmStatic
        private var sBackgroundFlutterEngine: FlutterEngine? = null

        @JvmStatic
        private val sServiceStarted = AtomicBoolean(false)

        @JvmStatic
        fun enqueueWork(context: Context, work: Intent) {
            enqueueWork(context, EventService::class.java, JOB_ID, work)
        }
    }

    private fun startEventService(context: Context) {
        synchronized(sServiceStarted) {
            this.context = context
            if (sBackgroundFlutterEngine == null) {
                val callbackHandle = context.getSharedPreferences(
                        EventPlugin.EVENT_PREFERENCES_KEY,
                        Context.MODE_PRIVATE)
                        .getLong(EventPlugin.CALLBACK_DISPATCHER_HANDLE_KEY, 0)
                if (callbackHandle == 0L) {
                    Log.e("UALibUlrich", "Fatal: no callback registered")
                    return
                }
                val callbackInfo = FlutterCallbackInformation.lookupCallbackInformation(callbackHandle)
                if (callbackInfo == null) {
                    Log.e("UALibUlrich", "Fatal: failed to find callback")
                    return
                }
                sBackgroundFlutterEngine = FlutterEngine(context)

                val args = DartExecutor.DartCallback(
                        context.assets,
                        FlutterInjector.instance().flutterLoader().findAppBundlePath(),
                        callbackInfo
                )
                // Start running callback dispatcher code in our background FlutterEngine instance.
                sBackgroundFlutterEngine!!.dartExecutor.executeDartCallback(args)
            }
        }

        mBackgroundChannel = MethodChannel(sBackgroundFlutterEngine!!.dartExecutor.binaryMessenger, "com.airship.flutter/event_plugin_background")
        mBackgroundChannel.setMethodCallHandler(this)
    }

    override fun onCreate() {
        super.onCreate()
        startEventService(this)
    }

    override fun onHandleWork(intent: Intent) {

        val payload = intent.extras?.get("payload")

        for (progress in 0..1000) {
            Log.d("UALibUlrich","New Isolate progress : $progress")
        }

        EventPlugin.test(payload as String)

        synchronized(sServiceStarted) {
            if (!sServiceStarted.get()) {
                queue.add(payload)
            } else {
                // Callback method name is intentionally left blank.
                mBackgroundChannel.invokeMethod("", payload)
            }
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "EventService.performed") {

            Log.d("UALibUlrich", "test Ulrich performed")

            synchronized(sServiceStarted) {
                while (!queue.isEmpty()) {
                    mBackgroundChannel.invokeMethod("", queue.remove())
                }
                sServiceStarted.set(true)
                result.success(null)
            }
        } else {
            result.notImplemented()
        }
    }

}