package com.airship.flutter

import android.content.Context
import android.graphics.Color
import android.net.Uri
import androidx.annotation.ColorInt
import androidx.datastore.core.CorruptionException
import androidx.datastore.core.Serializer
import com.airship.flutter.config.Config
import com.google.protobuf.InvalidProtocolBufferException
import com.urbanairship.AirshipConfigOptions
import com.urbanairship.PrivacyManager
import com.urbanairship.json.JsonList
import com.urbanairship.util.UAStringUtil
import java.io.InputStream
import java.io.OutputStream

object  ConfigSerializer: Serializer<Config.AirshipConfig>{
    override val defaultValue: Config.AirshipConfig = Config.AirshipConfig.getDefaultInstance()
    override suspend fun readFrom(input: InputStream): Config.AirshipConfig {
        try {
            return Config.AirshipConfig.parseFrom(input)
        } catch (exception: InvalidProtocolBufferException) {
            throw CorruptionException("Cannot read proto.", exception)
        }
    }

    override suspend fun writeTo(t: Config.AirshipConfig, output: OutputStream) {
        t.writeTo(output)
    }

}

/// perhaps move this to shared package to avoid duplication across sdks
object ConfigParser {

//    fun parse(context: Context, config: HashMap<*,*>?): AirshipConfigOptions? {
//        if (config == null || config.isEmpty()) {
//            return null
//        }
//
//        val builder = AirshipConfigOptions.newBuilder()
//            .setRequireInitialRemoteConfigEnabled(true)
//
//        val defaultEnvironment = Environment.fromJson(config["default"] as HashMap<*, *> ?/* = java.util.HashMap<*, *> */)
//        val developmentEnvironment = Environment.fromJson(config["development"] as HashMap<*, *> ?)
//        val productionEnvironment = Environment.fromJson(config["production"] as HashMap<*, *> ?)
//
//        if (defaultEnvironment.appKey != null && defaultEnvironment.appSecret != null) {
//            builder.setAppKey(defaultEnvironment.appKey)
//                .setAppSecret(defaultEnvironment.appSecret)
//        }
//
//        if (developmentEnvironment.appKey != null && developmentEnvironment.appSecret != null) {
//            builder.setDevelopmentAppKey(developmentEnvironment.appKey)
//                .setDevelopmentAppSecret(developmentEnvironment.appSecret)
//        }
//
//        if (productionEnvironment.appKey != null && productionEnvironment.appSecret != null) {
//            builder.setProductionAppKey(productionEnvironment.appKey)
//                .setProductionAppSecret(productionEnvironment.appSecret)
//        }
//
//        developmentEnvironment.logLevel?.let { builder.setDevelopmentLogLevel(it) }
//        defaultEnvironment.logLevel?.let { builder.setLogLevel(it) }
//        productionEnvironment.logLevel?.let { builder.setProductionLogLevel(it) }
//
//        parseSite(config["site"]?.toString())?.let { builder.setSite(it) }
//
//        if (config.containsKey("inProduction")) {
//            builder.setInProduction(config["inProduction"].toString().toBoolean())
//        }
//
//        parseArray(config["urlAllowList"] as List<String>?).let {
//            builder.setUrlAllowList(it)
//        }
//
//        parseArray(config["urlAllowListScopeJavaScriptInterface"] as List<String>?).let {
//            builder.setUrlAllowListScopeJavaScriptInterface(it)
//        }
//
//        parseArray(config["urlAllowListScopeOpenUrl"] as List<String>?).let {
//            builder.setUrlAllowListScopeOpenUrl(it)
//        }
//
//        (config["android"] as HashMap<*, *> ?)?.let { android ->
//            if (android.containsKey("appStoreUri")) {
//                builder.setAppStoreUri(
//                    Uri.parse(
//                        android["appStoreUri"].toString()
//                    )
//                )
//            }
//
//            if (android.containsKey("fcmFirebaseAppName")) {
//                builder.setFcmFirebaseAppName(android["fcmFirebaseAppName"].toString())
//            }
//
//            if (android.containsKey("notificationConfig")) {
//                applyNotificationConfig(
//                    context,
//                    android["notificationConfig"] as HashMap<String, *> /* = java.util.HashMap<kotlin.String, *> */,
//                    builder
//                )
//            }
//        }
//
//        (config["enabledFeatures"] as List<String>?)?.let {
//            builder.setEnabledFeatures(parseFeatures(it))
//        }
//
//        return builder.build()
//    }

    private fun applyNotificationConfig(
        context: Context,
        notificationConfig: HashMap<String, *>?,
        builder: AirshipConfigOptions.Builder
    ) {
        val icon = notificationConfig?.get("icon")?.toString()
        if (icon != null) {
            val resourceId = getNamedResource(context, icon, "drawable")
            builder.setNotificationIcon(resourceId)
        }
        val largeIcon = notificationConfig?.get("largeIcon")?.toString()
        if (largeIcon != null) {
            val resourceId = getNamedResource(context, largeIcon, "drawable")
            builder.setNotificationLargeIcon(resourceId)
        }
        val accentColor = notificationConfig?.get("accentColor")?.toString()
        if (accentColor != null) {
            builder.setNotificationAccentColor(getHexColor(accentColor, 0))
        }
        val channelId = notificationConfig?.get("defaultChannelId")?.toString()
        if (channelId != null) {
            builder.setNotificationChannel(channelId)
        }
    }

    @ColorInt
    fun getHexColor(hexColor: String?, @ColorInt defaultColor: Int): Int {
        if (hexColor.isNullOrEmpty()){
            return  defaultColor;
        }
        return Color.parseColor(hexColor)?:defaultColor
    }

     fun getNamedResource(context: Context, resourceName: String, resourceFolder: String): Int {
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

    private fun parseArray(value: List<String>?): Array<String?>? {
        if (value == null) {
            return null
        }
        return value.toTypedArray()
    }

    @PrivacyManager.Feature
    private fun parseFeatures(jsonList: List<String>): Int {
        var result = PrivacyManager.FEATURE_NONE
        for (value in jsonList) {
            result = result or parseFeature(value.toString())
        }
        return result
    }

    @PrivacyManager.Feature
    fun parseFeature(name: String): Int {
        return FeatureEnable.valueOf(name.uppercase()).featureSupportLevel()
    }

    @AirshipConfigOptions.Site
    private fun parseSite(value: String?): String? {
        if (value == null) {
            return null
        }

        return when (value.lowercase()) {
            AirshipConfigOptions.SITE_EU.lowercase() -> AirshipConfigOptions.SITE_EU
            AirshipConfigOptions.SITE_US.lowercase() -> AirshipConfigOptions.SITE_US
            else -> throw IllegalArgumentException("Invalid site $value")
        }
    }
}

