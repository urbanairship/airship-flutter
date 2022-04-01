package com.airship.flutter

import android.util.Log
import android.content.Context
import androidx.annotation.NonNull
import androidx.core.app.NotificationCompat
import com.airship.flutter.events.*
import com.urbanairship.Autopilot
import com.urbanairship.UAirship
import com.urbanairship.messagecenter.MessageCenter
import com.urbanairship.push.*
import com.urbanairship.push.notifications.AirshipNotificationProvider
import com.urbanairship.push.notifications.NotificationArguments
import androidx.annotation.XmlRes
import com.airship.flutter.AirshipBackgroundExecutor.Companion.handleBackgroundMessage
import com.urbanairship.AirshipConfigOptions
import com.urbanairship.UAirship.getApplicationContext
import com.urbanairship.analytics.Analytics
import com.urbanairship.channel.AirshipChannelListener
import com.urbanairship.preferencecenter.PreferenceCenter
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.runBlocking

const val PUSH_MESSAGE_BUNDLE_EXTRA = "com.urbanairship.push_bundle"

class FlutterAutopilot : Autopilot() {
    var config: AirshipConfigOptions? = null

    private val appContext: Context
        get() = getApplicationContext()

    override fun onAirshipReady(airship: UAirship) {
        super.onAirshipReady(airship)

        Log.i("FlutterAutopilot", "onAirshipReady")

        // If running in the background, start the background Isolate
        // so that we can communicate with the Flutter app.
        if (!appContext.isAppInForeground()) {
            AirshipBackgroundExecutor.startIsolate(appContext)
        }

        // Register a listener for inbox update event
        MessageCenter.shared().inbox.addListener {
            EventManager.shared.notifyEvent(InboxUpdatedEvent())
        }

        airship.pushManager.notificationProvider = object : AirshipNotificationProvider(appContext, airship.airshipConfigOptions) {
            override fun onExtendBuilder(context: Context, builder: NotificationCompat.Builder, arguments: NotificationArguments): NotificationCompat.Builder {
                builder.extras.putBundle(PUSH_MESSAGE_BUNDLE_EXTRA, arguments.message.pushBundle)
                return super.onExtendBuilder(context, builder, arguments)
            }
        }

        airship.pushManager.addPushListener{ message, notificationPosted ->
            if (notificationPosted) return@addPushListener

            if (!appContext.isAppInForeground()) {
                handleBackgroundMessage(appContext, message)
            }

            post(PushReceivedEvent(message))
        }

        airship.pushManager.notificationListener = object : NotificationListener {
            override fun onNotificationPosted(@NonNull notificationInfo: NotificationInfo) {
                if (!appContext.isAppInForeground()) {
                    handleBackgroundMessage(appContext, notificationInfo.message, notificationInfo)
                }

                post(PushReceivedEvent(notificationInfo.message, notificationInfo))
            }

            override fun onNotificationOpened(@NonNull notificationInfo: NotificationInfo): Boolean {
                post(NotificationResponseEvent(notificationInfo))
                return false
            }

            override fun onNotificationForegroundAction(@NonNull notificationInfo: NotificationInfo, @NonNull notificationActionButtonInfo: NotificationActionButtonInfo): Boolean {
                post(NotificationResponseEvent(notificationInfo, notificationActionButtonInfo))
                return false
            }

            override fun onNotificationBackgroundAction(@NonNull notificationInfo: NotificationInfo, @NonNull notificationActionButtonInfo: NotificationActionButtonInfo) {
                post(NotificationResponseEvent(notificationInfo, notificationActionButtonInfo))
            }

            override fun onNotificationDismissed(@NonNull notificationInfo: NotificationInfo) {}
        }

        airship.channel.addChannelListener(object : AirshipChannelListener {
            override fun onChannelCreated(channelId: String) {
                post(ChannelRegistrationEvent(channelId, UAirship.shared().pushManager.pushToken))
            }

            override fun onChannelUpdated(channelId: String) {
                post(ChannelRegistrationEvent(channelId, UAirship.shared().pushManager.pushToken))
            }
        })

        MessageCenter.shared().setOnShowMessageCenterListener(object : MessageCenter.OnShowMessageCenterListener {
            override fun onShowMessageCenter(messageId: String?): Boolean {
                if (messageId != null) {
                    EventManager.shared.notifyEvent(ShowInboxMessageEvent(messageId))
                    return true
                }

                EventManager.shared.notifyEvent(ShowInboxEvent())
                return true
            }
        })

        airship.setDeepLinkListener { deepLink ->
            EventManager.shared.notifyEvent(DeepLinkEvent(deepLink))
            true
        }

        PreferenceCenter.shared().openListener =  object : PreferenceCenter.OnOpenListener {
            override fun onOpenPreferenceCenter(preferenceCenterId: String): Boolean {
                val preferences =  getApplicationContext().getSharedPreferences("com.urbanairship.flutter", Context.MODE_PRIVATE)
                val enabled = preferences.getBoolean(AUTO_LAUNCH_PREFERENCE_CENTER_KEY, true)

                if (enabled) {
                    return false
                } else {
                    EventManager.shared.notifyEvent(ShowPreferenceCenterEvent(preferenceCenterId))
                    return true
                }
            }
        }

        airship.getAnalytics().registerSDKExtension(Analytics.EXTENSION_FLUTTER, AirshipPluginVersion.AIRSHIP_PLUGIN_VERSION);

        loadCustomNotificationChannels(appContext, airship)
        loadCustomNotificationButtonGroups(appContext, airship)
    }

    private fun loadCustomNotificationChannels(context: Context, airship: UAirship) {
        val packageName = UAirship.getPackageName()
        @XmlRes val resId = context.resources.getIdentifier("ua_custom_notification_channels", "xml", packageName)

        if (resId != 0) {
            airship.pushManager.notificationChannelRegistry.createNotificationChannels(resId)
        }
    }

    private fun loadCustomNotificationButtonGroups(context: Context, airship: UAirship) {
        val packageName = UAirship.getPackageName()
        @XmlRes val resId = context.resources.getIdentifier("ua_custom_notification_buttons", "xml", packageName)

        if (resId != 0) {
            airship.pushManager.addNotificationActionButtonGroups(context, resId)
        }
    }

    private fun post(event: Event) = EventManager.shared.notifyEvent(event)

    override fun isReady(context: Context): Boolean {
        val config = runBlocking(Dispatchers.IO) {
            ConfigManager.shared(context).config.first()
        }

        return if (config.isValid()) {
            this.config = config
            true
        } else {
            false
        }
    }

    override fun createAirshipConfigOptions(context: Context): AirshipConfigOptions? {
        return config
    }
}
