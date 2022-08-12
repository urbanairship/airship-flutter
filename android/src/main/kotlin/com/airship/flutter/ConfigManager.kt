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
import com.google.protobuf.GeneratedMessageV3
import com.urbanairship.AirshipConfigOptions
import com.urbanairship.PrivacyManager
import com.urbanairship.util.UAStringUtil
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.flow

class ConfigManager(private val context: Context) {
    companion object {

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
            ConfigSerializer.readFrom(  configByteArray.inputStream())
        }
    }

    val config: Flow<AirshipConfigOptions>
        get() = flow {
            /// Plugin config stored/ from dart config
            val pluginConfig = context.flutterPluginStore.data.first()

            val config = AirshipConfigOptions.newBuilder()
                .applyDefaultProperties(context)
                .setRequireInitialRemoteConfigEnabled(pluginConfig.requireInitialRemoteConfigEnabled)
                .apply {
                    pluginConfig.inProduction.let {
                        this.setInProduction(it)
                    }

                    pluginConfig.development.let {
                        if (it.isNotEmptyOrPartial) {
                            this.setDevelopmentAppKey(it.appKey)
                                .setDevelopmentAppSecret(it.appSecret)
                                .setDevelopmentLogLevel(it.logLevel.value)
                        }
                    }

                    pluginConfig.production.let {
                        if (it.isNotEmptyOrPartial) {
                            this.setProductionAppKey(it.appKey)
                                .setProductionAppSecret(it.appSecret)
                                .setProductionLogLevel(it.logLevel.value)
                        }
                    }

                    /// since proto buf defaults to empty string,
                    // check for empty string instead of null
                    pluginConfig.defaultEnv.let {
                        if (it.isNotEmptyOrPartial) {
                            this.setAppKey(it.appKey)
                                .setAppSecret(it.appSecret)
                                .setLogLevel(it.logLevel.value)
                        }
                    }

                    this.setSite(
                        when (pluginConfig.site) {
                            Config.Site.SITE_EU -> {
                                AirshipConfigOptions.SITE_EU
                            }
                            Config.Site.SITE_US -> {
                                AirshipConfigOptions.SITE_US
                            }
                            Config.Site.UNRECOGNIZED -> {
                                AirshipConfigOptions.SITE_US
                            }
                            else -> AirshipConfigOptions.SITE_US
                        }
                    )

                    pluginConfig.urlAllowListList.let {
                        if (it.isNotEmpty()){
                            this.setUrlAllowList(it.toTypedArray())
                        }
                    }

                    pluginConfig.urlAllowListScopeOpenUrlList.let {
                        if (it.isNotEmpty()){
                            this.setUrlAllowListScopeOpenUrl(it.toTypedArray())
                        }
                    }

                    pluginConfig.urlAllowlistScopeJavascriptInterfaceList.let {
                        if (it.isNotEmpty()){
                            this.setUrlAllowListScopeJavaScriptInterface(it.toTypedArray())
                        }
                    }

                    this.setEnabledFeatures(pluginConfig.featuresEnabledList.supportValue())

                    pluginConfig.android.appStoreUri.let {
                        if (it.isNotEmpty()){
                            this.setAppStoreUri(Uri.parse(it))
                        }
                    }

                    pluginConfig.android.fcmFirebaseAppName.let {
                        if (it.isNotEmpty()){
                            this.setFcmFirebaseAppName(it)
                        }
                    }
                    pluginConfig.android.notification.accentColor.let {
                        if (it.isNotEmpty()) this.setNotificationAccentColor(
                            getHexColor(it)
                        )
                    }

                    pluginConfig.android.notification.defaultChannelId.let {
                        if (it.isNotEmpty()) this.setNotificationChannel(it)
                    }

                    pluginConfig.android.notification.largeIcon.let {
                        if (it.isNotEmpty()) this.setNotificationIcon(
                            getNamedResource(
                                context,
                                it
                            )
                        )
                    }

                    pluginConfig.android.notification.largeIcon.let {
                        if (it.isNotEmpty()) this.setNotificationLargeIcon(
                            getNamedResource(
                                context,
                                it,

                            )
                        )
                    }

                    pluginConfig.android.notification.defaultChannelId.let {
                        if (it.isNotEmpty()) this.setNotificationChannel(it)
                    }
                }
                .build()
            emit(config)
        }


    @ColorInt
    fun getHexColor(hexColor: String): Int {
        return Color.parseColor(hexColor)
    }

    private fun getNamedResource(
        context: Context,
        resourceName: String
    ): Int {
        if (!UAStringUtil.isEmpty(resourceName)) {
            val id =
                context.resources.getIdentifier(resourceName, "drawable", context.packageName)
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
    if (isEmpty()){
        return PrivacyManager.FEATURE_ALL
    }
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
        Config.Feature.UNRECOGNIZED -> PrivacyManager.FEATURE_ALL
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

val GeneratedMessageV3.isEmptyOPartial: Boolean
    get() = allFields.isEmpty() || allFields.size < javaClass.fields.size || allFields.values.any {
        it.toString().isEmpty()
    }


val GeneratedMessageV3.isNotEmptyOrPartial: Boolean
    get() = !isEmptyOPartial