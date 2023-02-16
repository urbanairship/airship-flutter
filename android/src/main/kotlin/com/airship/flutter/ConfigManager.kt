package com.airship.flutter

import android.annotation.SuppressLint
import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import com.urbanairship.AirshipConfigOptions
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.withContext

class ConfigManager(private val context: Context) {
    companion object {
        private val APP_KEY = stringPreferencesKey("app_key")
        private val APP_SECRET = stringPreferencesKey("app_secret")

        @SuppressLint("StaticFieldLeak")
        @Volatile
        private var instance: ConfigManager? = null

        fun shared(context: Context): ConfigManager = instance ?: synchronized(this) {
            instance ?: ConfigManager(context.applicationContext).also { instance = it }
        }
    }

    private val Context.airshipFlutterPluginStore: DataStore<Preferences> by preferencesDataStore(
        name = "airshipFlutterPlugin"
    )

    suspend fun updateConfig(appKey: String, appSecret: String) {
        context.airshipFlutterPluginStore.edit { preferences ->
            preferences[APP_KEY] = appKey
            preferences[APP_SECRET] = appSecret
        }
    }

    val config: Flow<AirshipConfigOptions>
        get() = flow {
            val appCredentialsOverride =
                context.airshipFlutterPluginStore.data.map { preferences ->
                    Pair(preferences[APP_KEY], preferences[APP_SECRET])
                }.first()

            val config = AirshipConfigOptions.newBuilder()
                .applyDefaultProperties(context)
                .apply {
                    if (!(appCredentialsOverride.first.isNullOrEmpty() || appCredentialsOverride.second.isNullOrEmpty())) {
                        this.setAppKey(appCredentialsOverride.first)
                            .setAppSecret(appCredentialsOverride.second)
                            .build()
                    }
                }
                .build()

            emit(config)
        }
}

