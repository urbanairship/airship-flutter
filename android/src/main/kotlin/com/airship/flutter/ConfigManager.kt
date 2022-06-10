package com.airship.flutter

import android.annotation.SuppressLint
import android.content.Context
import android.net.Uri
import androidx.datastore.core.DataStore
import androidx.datastore.dataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import com.airship.flutter.ConfigParser.getHexColor
import com.airship.flutter.ConfigParser.getNamedResource
import com.airship.flutter.config.Config
import com.urbanairship.AirshipConfigOptions
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.map

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
        name = "airshipFlutterPlugin",
    )

    private val Context.flutterPluginStore: DataStore<Config.AirshipConfig> by dataStore(
        fileName = "airship.flutter.plugin.pb",
        ConfigSerializer
    )

    suspend fun updateConfig(appKey: String, appSecret: String) {
        context.airshipFlutterPluginStore.edit { preferences ->
            preferences[APP_KEY] = appKey
            preferences[APP_SECRET] = appSecret
        }
    }

    suspend fun updateConfig(configByteArray: ByteArray) {
        val appCredentialsOverride =
            context.airshipFlutterPluginStore.data.map { preferences ->
                Pair(preferences[APP_KEY], preferences[APP_SECRET])
            }.first()
        context.flutterPluginStore.updateData {
            Config.AirshipConfig.parseFrom(configByteArray).apply {
                // if either appKey/secretKey for default have been left blank in flutter
                // and  if we have appCredential stored in preferences they are used to override
                // defaultEnv
                if (defaultEnv.allFields.any { toString().isEmpty() }) {
                    if (!(appCredentialsOverride.first.isNullOrEmpty() || appCredentialsOverride.second.isNullOrEmpty())) {
                        this.defaultEnv.toBuilder().apply {
                            appKey = appCredentialsOverride.first
                            appSecret = appCredentialsOverride.second
                        }.build()
                    }
                }
            }
        }
    }

    val config: Flow<AirshipConfigOptions>
        get() = flow {
            val pluginConfig = context.flutterPluginStore.data.first()

            val config = AirshipConfigOptions.newBuilder()
                .applyDefaultProperties(context)
                .apply {
                    this.setAppKey(pluginConfig.defaultEnv.appKey)
                        .setAppSecret(pluginConfig.defaultEnv.appSecret)
                        .setLogLevel(pluginConfig.defaultEnv.logLevel.parse)
                        .build()

                    this.setDevelopmentAppKey(pluginConfig.development.appKey)
                        .setDevelopmentAppSecret(pluginConfig.development.appSecret)
                        .setDevelopmentLogLevel(pluginConfig.development.logLevel.parse)
                        .build()

                    this.setProductionAppKey(pluginConfig.production.appKey)
                        .setProductionAppSecret(pluginConfig.production.appSecret)
                        .setProductionLogLevel(pluginConfig.production.logLevel.parse)
                        .build()
                    this.setAppStoreUri(Uri.parse(pluginConfig.android.appStoreUri))
                    this.setFcmFirebaseAppName(pluginConfig.android.fcmFirebaseAppName)
                    this.setNotificationAccentColor(
                        getHexColor( pluginConfig.android.notification.accentColor, 0x000)
                       )
                    this.setNotificationChannel(pluginConfig.android.notification.defaultChannelId)
                    this.setNotificationIcon(
                        getNamedResource(
                            context,
                            pluginConfig.android.notification.largeIcon,
                            "drawable"
                        )
                    )
                    this.setNotificationLargeIcon(
                        getNamedResource(
                            context,
                            pluginConfig.android.notification.largeIcon,
                            "drawable"
                        )
                    )



                }
                .build()

            emit(config)
        }
}


fun AirshipConfigOptions.isValid(): Boolean {
    if (this.appKey.isEmpty() || this.appSecret.isEmpty()) {
        return false
    }

    return try {
        validate()
        true
    } catch (e: IllegalArgumentException) {
        false
    }
}