package com.airship.flutter

import android.content.Context
import android.util.Log
import com.urbanairship.UAirship
import com.urbanairship.analytics.Analytics
import com.urbanairship.android.framework.proxy.BaseAutopilot
import com.urbanairship.android.framework.proxy.ProxyStore

class FlutterAutopilot : BaseAutopilot() {

    private val appContext: Context
        get() = UAirship.getApplicationContext()

    override fun onAirshipReady(airship: UAirship) {
        super.onAirshipReady(airship)

        Log.i("FlutterAutopilot", "onAirshipReady")

        // If running in the background, start the background Isolate
        // so that we can communicate with the Flutter app.
        if (!appContext.isAppInForeground()) {
            AirshipBackgroundExecutor.startIsolate(appContext)
        }

        airship.analytics.registerSDKExtension(Analytics.EXTENSION_FLUTTER, AirshipPluginVersion.AIRSHIP_PLUGIN_VERSION);
    }

    override fun onMigrateData(context: Context, proxyStore: ProxyStore) {
        // TODO
    }
}
