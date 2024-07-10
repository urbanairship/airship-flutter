package com.airship.flutter

import android.content.Context
import android.content.Context.MODE_PRIVATE
import android.util.Log
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import com.airship.flutter.AirshipBackgroundExecutor.Companion.handleBackgroundMessage
import com.urbanairship.UAirship
import com.urbanairship.analytics.Analytics
import com.urbanairship.analytics.Extension
import com.urbanairship.android.framework.proxy.BaseAutopilot
import com.urbanairship.android.framework.proxy.EventType
import com.urbanairship.android.framework.proxy.ProxyConfig
import com.urbanairship.android.framework.proxy.ProxyStore
import com.urbanairship.android.framework.proxy.events.EventEmitter
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.flow.filter
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking

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

        airship.analytics.registerSDKExtension(Extension.FLUTTER, AirshipPluginVersion.AIRSHIP_PLUGIN_VERSION);
    }

    override fun onMigrateData(context: Context, proxyStore: ProxyStore) {
        runBlocking {
            context.airshipFlutterPluginStore.data.map { preferences ->
                val key = preferences[APP_KEY] ?: return@map null
                val secret = preferences[APP_SECRET] ?: return@map null
                ProxyConfig.Environment(key, secret, null)
            }.first()?.let {
                context.airshipFlutterPluginStore.edit { preferences ->
                    preferences.clear()
                }
                proxyStore.airshipConfig = ProxyConfig(defaultEnvironment = it)
            }
        }
    }


    companion object {
        private val APP_KEY = stringPreferencesKey("app_key")
        private val APP_SECRET = stringPreferencesKey("app_secret")
    }

    private val Context.airshipFlutterPluginStore: DataStore<Preferences> by preferencesDataStore(
            name = "airshipFlutterPlugin"
    )
}
