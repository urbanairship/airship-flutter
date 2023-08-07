package com.airship.flutter

import android.content.Context
import android.util.Log
import com.airship.flutter.AirshipBackgroundExecutor.Companion.handleBackgroundMessage
import com.urbanairship.UAirship
import com.urbanairship.analytics.Analytics
import com.urbanairship.android.framework.proxy.BaseAutopilot
import com.urbanairship.android.framework.proxy.EventType
import com.urbanairship.android.framework.proxy.ProxyStore
import com.urbanairship.android.framework.proxy.events.EventEmitter
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.flow.filter
import kotlinx.coroutines.launch

class FlutterAutopilot : BaseAutopilot() {

    private val appContext: Context
        get() = UAirship.getApplicationContext()

    override fun onAirshipReady(airship: UAirship) {
        super.onAirshipReady(airship)

        Log.i("FlutterAutopilot", "onAirshipReady")

        // If running in the background, start the background Isolate
        // so that we can communicate with the Flutter app.
        AirshipBackgroundExecutor.startIsolate(appContext)

        MainScope().launch {
            EventEmitter.shared().pendingEventListener.filter {
                it.type == EventType.BACKGROUND_PUSH_RECEIVED
            }.collect {event ->
                EventEmitter.shared().takePending(listOf(event.type)).forEach {
                    handleBackgroundMessage(appContext, it.body)
                }
            }
        }

        airship.analytics.registerSDKExtension(Analytics.EXTENSION_FLUTTER, AirshipPluginVersion.AIRSHIP_PLUGIN_VERSION);
    }

    override fun onMigrateData(context: Context, proxyStore: ProxyStore) {
        // TODO
    }
}
