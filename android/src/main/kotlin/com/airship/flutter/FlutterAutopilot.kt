package com.airship.flutter

import android.content.Context
import android.util.Log
import androidx.datastore.core.CorruptionException
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import androidx.datastore.preferences.preferencesDataStoreFile
import com.airship.flutter.AirshipBackgroundExecutor.Companion.handleBackgroundMessage
import com.urbanairship.Airship
import com.urbanairship.analytics.Extension
import com.urbanairship.android.framework.proxy.BaseAutopilot
import com.urbanairship.android.framework.proxy.events.EventType
import com.urbanairship.android.framework.proxy.ProxyConfig
import com.urbanairship.android.framework.proxy.ProxyStore
import com.urbanairship.android.framework.proxy.events.EventEmitter
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.flow.filter
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withTimeout

class FlutterAutopilot : BaseAutopilot() {

    private val appContext: Context
        get() = Airship.application.applicationContext

    override fun onReady(context: Context) {
        Log.i("FlutterAutopilot", "onReady")

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

        Airship.analytics.registerSDKExtension(Extension.FLUTTER, AirshipPluginVersion.AIRSHIP_PLUGIN_VERSION)
    }

    override fun onMigrateData(context: Context, proxyStore: ProxyStore) {
        // Called on the main thread during takeOff, so the store is opened only when there is
        // a file to read.
        val storeFile = context.applicationContext.preferencesDataStoreFile(PLUGIN_STORE_NAME)
        if (!storeFile.exists()) {
            return
        }

        try {
            runBlocking {
                withTimeout(MIGRATION_TIMEOUT_MS) {
                    context.airshipFlutterPluginStore.data.map { preferences ->
                        val key = preferences[APP_KEY] ?: return@map null
                        val secret = preferences[APP_SECRET] ?: return@map null
                        ProxyConfig.Environment(key, secret, null)
                    }.first()?.let {
                        proxyStore.airshipConfig = ProxyConfig(defaultEnvironment = it)
                    }
                }
            }
        } catch (e: CorruptionException) {
            // An unparseable store throws on every read, so keeping it would stall each later
            // launch for the full timeout. The config is unrecoverable either way.
            Log.w("FlutterAutopilot", "Plugin store is unreadable, discarding it without migrating", e)
        } catch (e: Exception) {
            // Anything else may be transient, so the file stays for the next launch to retry:
            // an app whose config lives only in the store cannot take off without it.
            Log.e("FlutterAutopilot", "Failed to migrate the Airship config from the plugin store", e)
            return
        }

        // The gate above keys on the file existing, so the file itself has to go: clearing its
        // contents would leave every later launch opening the store.
        if (!storeFile.delete()) {
            // A surviving file migrates again next launch, overwriting a config the app has
            // set from Dart in the meantime.
            Log.w("FlutterAutopilot", "Could not delete the migrated plugin store at ${storeFile.path}")
        }
    }

    companion object {
        // Written by plugin versions before 7.0.0; nothing has written it since.
        private const val PLUGIN_STORE_NAME = "airshipFlutterPlugin"
        private const val MIGRATION_TIMEOUT_MS = 3_000L
        private val APP_KEY = stringPreferencesKey("app_key")
        private val APP_SECRET = stringPreferencesKey("app_secret")
    }

    private val Context.airshipFlutterPluginStore: DataStore<Preferences> by preferencesDataStore(
            name = PLUGIN_STORE_NAME
    )
}
