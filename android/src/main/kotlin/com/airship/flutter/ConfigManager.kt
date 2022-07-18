package com.airship.flutter

import PluginLogger
import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Color
import android.net.Uri
import android.util.Log
import androidx.annotation.ColorInt
import androidx.datastore.core.DataStore
import androidx.datastore.dataStore
import com.airship.flutter.config.Config
import com.urbanairship.AirshipConfigOptions
import com.urbanairship.PrivacyManager
import com.urbanairship.util.UAStringUtil
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.map

private val Config.AirshipEnv.isSet: Boolean
    get() {
        return isInitialized && allFields.size == 3;
    }

class ConfigManager(private val context: Context) {
    companion object {
     /*   private val APP_KEY = stringPreferencesKey("app_key")
        private val APP_SECRET = stringPreferencesKey("app_secret")*/

        @SuppressLint("StaticFieldLeak")
        @Volatile
        private var instance: ConfigManager? = null

        fun shared(context: Context): ConfigManager = instance ?: synchronized(this) {
            instance ?: ConfigManager(context.applicationContext).also { instance = it }
        }
    }



    private val Context.flutterPluginStore: DataStore<Config.AirshipConfig> by dataStore(
        fileName = "airship.flutter.plugin.pb",
        ConfigSerializer
    )

    suspend fun updateConfig(configByteArray: ByteArray) {
        context.flutterPluginStore.updateData {
            Config.AirshipConfig.parseFrom(configByteArray);
        }
    }

    val config: Flow<AirshipConfigOptions>
        get() = flow {
            /// Plugin config stored/ from dart config
            val pluginConfig = context.flutterPluginStore.data.first()

            val config = AirshipConfigOptions.newBuilder()
                .applyDefaultProperties(context)
                .setRequireInitialRemoteConfigEnabled(true)
                .apply {
                    /// since proto buf defaults to empty string,
                    // check for empty string instead of null
                    pluginConfig.defaultEnv.let {
                        this.setAppKey(it.appKey)
                            .setAppSecret(it.appSecret)
                            .setLogLevel(it.logLevel.value)
                            .build()
                    }

                    pluginConfig.development.let {
                        this.setDevelopmentAppKey(it.appKey)
                            .setDevelopmentAppSecret(it.appSecret)
                            .setDevelopmentLogLevel(it.logLevel.value)
                            .build()
                    }
                    pluginConfig.production.let {
                        this.setProductionAppKey(it.appKey)
                            .setProductionAppSecret(it.appSecret)
                            .setProductionLogLevel(it.logLevel.value)
                            .build()
                    }


                    this.setSite(
                        when (pluginConfig.site) {
                            Config.Site.SITE_EU -> AirshipConfigOptions.SITE_EU
                            Config.Site.SITE_US -> AirshipConfigOptions.SITE_US
                            Config.Site.UNRECOGNIZED -> AirshipConfigOptions.SITE_US
                        }
                    )

                    pluginConfig.inProduction.let {
                        this.setInProduction(it)
                    }

                    pluginConfig.urlAllowListList.let {
                        this.setUrlAllowList(null/*it.toTypedArray()*/)
                    }

                    pluginConfig.urlAllowlistScopeJavascriptInterfaceList.let {
                        this.setUrlAllowListScopeJavaScriptInterface(it.toTypedArray())
                    }

                    pluginConfig.urlAllowListScopeOpenUrlList.let {
                        this.setUrlAllowListScopeOpenUrl(it.toTypedArray())
                    }

                    this.setEnabledFeatures(pluginConfig.featuresEnabledList.supportValue())

                    this.setAppStoreUri(Uri.parse(pluginConfig.android.appStoreUri))
                    this.setFcmFirebaseAppName(pluginConfig.android.fcmFirebaseAppName)
                    this.setNotificationAccentColor(
                        getHexColor(pluginConfig.android.notification.accentColor, 0x000)
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
                    this.setNotificationChannel(pluginConfig.android.notification.defaultChannelId)


                }
                .build()

            emit(config)
        }


    @ColorInt
    fun getHexColor(hexColor: String?, @ColorInt defaultColor: Int): Int {
        if (hexColor.isNullOrEmpty()) {
            return defaultColor;
        }
        return Color.parseColor(hexColor)
    }

    private fun getNamedResource(
        context: Context,
        resourceName: String,
        resourceFolder: String
    ): Int {
        if (!UAStringUtil.isEmpty(resourceName)) {
            val id =
                context.resources.getIdentifier(resourceName, resourceFolder, context.packageName)
            if (id != 0) {
                return id
            } else {
                PluginLogger.error("Unable to find resource with name: %s", resourceName)
            }
        }
        return 0
    }

}

fun List<Config.Feature>.supportValue(): Int {
    var result = PrivacyManager.FEATURE_NONE
    for (feature in this) {
        result = result or feature.value()
    }
    return result
}

fun Config.Feature.value(): Int {
    return when (this) {
        Config.Feature.ENABLE_ALL -> PrivacyManager.FEATURE_ALL
        Config.Feature.ENABLE_NONE -> PrivacyManager.FEATURE_NONE
        Config.Feature.ENABLE_IN_APP_AUTOMATION -> PrivacyManager.FEATURE_IN_APP_AUTOMATION
        Config.Feature.ENABLE_MESSAGE_CENTER -> PrivacyManager.FEATURE_MESSAGE_CENTER
        Config.Feature.ENABLE_PUSH -> PrivacyManager.FEATURE_PUSH
        Config.Feature.ENABLE_CHAT -> PrivacyManager.FEATURE_CHAT
        Config.Feature.ENABLE_ANALYTICS -> PrivacyManager.FEATURE_ANALYTICS
        Config.Feature.ENABLE_TAGS_AND_ATTRIBUTES -> PrivacyManager.FEATURE_TAGS_AND_ATTRIBUTES
        Config.Feature.ENABLE_CONTACTS -> PrivacyManager.FEATURE_CONTACTS
        Config.Feature.ENABLE_LOCATION -> PrivacyManager.FEATURE_LOCATION
        Config.Feature.UNRECOGNIZED -> PrivacyManager.FEATURE_NONE
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

val Config.LogLevel.value: Int
    get() {
        return when (this) {
            Config.LogLevel.VERBOSE -> Log.VERBOSE
            Config.LogLevel.DEBUG -> Log.DEBUG
            Config.LogLevel.INFO -> Log.INFO
            Config.LogLevel.WARN -> Log.WARN
            Config.LogLevel.ERROR -> Log.ERROR
            Config.LogLevel.NONE -> Log.ASSERT
            else -> Log.ASSERT
        }
    }
