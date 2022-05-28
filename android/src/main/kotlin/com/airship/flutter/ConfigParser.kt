package com.airship.flutter

import android.content.Context
import android.net.Uri
import androidx.annotation.ColorInt
import com.urbanairship.AirshipConfigOptions
import com.urbanairship.PrivacyManager
import com.urbanairship.json.JsonList
import com.urbanairship.json.JsonMap
import com.urbanairship.json.JsonValue
import com.urbanairship.util.UAStringUtil

/// perhaps move this to shared package to avoid duplication across sdks
object ConfigParser {

    fun parse(context: Context, config: JsonMap?): AirshipConfigOptions? {
        if (config == null || config.isEmpty) {
            return null
        }

        val builder = AirshipConfigOptions.newBuilder()
            .setRequireInitialRemoteConfigEnabled(true)

        val defaultEnvironment = Environment.fromJson(config.opt("default").map)
        val developmentEnvironment = Environment.fromJson(config.opt("development").map)
        val productionEnvironment = Environment.fromJson(config.opt("production").map)

        if (defaultEnvironment.appKey != null && defaultEnvironment.appSecret != null) {
            builder.setAppKey(defaultEnvironment.appKey)
                .setAppSecret(defaultEnvironment.appSecret)
        }

        if (developmentEnvironment.appKey != null && developmentEnvironment.appSecret != null) {
            builder.setDevelopmentAppKey(developmentEnvironment.appKey)
                .setDevelopmentAppSecret(developmentEnvironment.appSecret)
        }

        if (productionEnvironment.appKey != null && productionEnvironment.appSecret != null) {
            builder.setProductionAppKey(productionEnvironment.appKey)
                .setProductionAppSecret(productionEnvironment.appSecret)
        }

        developmentEnvironment.logLevel?.let { builder.setDevelopmentLogLevel(it) }
        defaultEnvironment.logLevel?.let { builder.setLogLevel(it) }
        productionEnvironment.logLevel?.let { builder.setProductionLogLevel(it) }

        parseSite(config.opt("site").string)?.let { builder.setSite(it) }

        if (config.containsKey("inProduction")) {
            builder.setInProduction(config.opt("inProduction").getBoolean(false))
        }

        parseArray(config.opt("urlAllowList")).let {
            builder.setUrlAllowList(it)
        }

        parseArray(config.opt("urlAllowListScopeJavaScriptInterface")).let {
            builder.setUrlAllowListScopeJavaScriptInterface(it)
        }

        parseArray(config.opt("urlAllowListScopeOpenUrl")).let {
            builder.setUrlAllowListScopeOpenUrl(it)
        }

        config.opt("android").map?.let { android ->
            if (android.containsKey("appStoreUri")) {
                builder.setAppStoreUri(
                    Uri.parse(
                        android.opt("appStoreUri").optString()
                    )
                )
            }

            if (android.containsKey("fcmFirebaseAppName")) {
                builder.setFcmFirebaseAppName(android.opt("fcmFirebaseAppName").optString())
            }

            if (android.containsKey("notificationConfig")) {
                applyNotificationConfig(
                    context,
                    android.opt("notificationConfig").optMap(),
                    builder
                )
            }
        }

        config.opt("enabledFeatures").list?.let {
            builder.setEnabledFeatures(parseFeatures(it))
        }

        return builder.build()
    }

    private fun applyNotificationConfig(
        context: Context,
        notificationConfig: JsonMap,
        builder: AirshipConfigOptions.Builder
    ) {
        val icon = notificationConfig.opt("icon").string
        if (icon != null) {
            val resourceId = getNamedResource(context, icon, "drawable")
            builder.setNotificationIcon(resourceId)
        }
        val largeIcon = notificationConfig.opt("largeIcon").string
        if (largeIcon != null) {
            val resourceId = getNamedResource(context, largeIcon, "drawable")
            builder.setNotificationLargeIcon(resourceId)
        }
        val accentColor = notificationConfig.opt("accentColor").integer
        if (accentColor != null) {
            builder.setNotificationAccentColor(getHexColor(accentColor, 0))
        }
        val channelId = notificationConfig.opt("defaultChannelId").string
        if (channelId != null) {
            builder.setNotificationChannel(channelId)
        }
    }

    @ColorInt
    fun getHexColor(hexColor: Int?, @ColorInt defaultColor: Int): Int {
        return hexColor?:defaultColor
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

    private fun parseArray(value: JsonValue?): Array<String?>? {
        if (value == null || !value.isJsonList) {
            return null
        }
        return value.optList().map {
            it.string ?: it.toString()
        }.toTypedArray()
    }

    @PrivacyManager.Feature
    private fun parseFeatures(jsonList: JsonList): Int {
        var result = PrivacyManager.FEATURE_NONE
        for (value in jsonList) {
            result = result or parseFeature(value.optString())
        }
        return result
    }

    @PrivacyManager.Feature
    fun parseFeature(name: String): Int {
        return EnabledFeature.valueOf(name.uppercase()).featureSupportLevel()
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

internal data class Environment(
    val appKey: String?,
    val appSecret: String?,
    val logLevel: Int?
) {
    companion object {
        fun fromJson(jsonMap: JsonMap?): Environment {
            val appKey = jsonMap?.opt("appKey")?.string
            val appSecret = jsonMap?.opt("appSecret")?.string
            val logLevel = jsonMap?.opt("logLevel")?.string?.uppercase()
                ?.let { LogLevel.valueOf(it).logLevel() }

            return Environment(appKey, appSecret, logLevel)
        }
    }
}

