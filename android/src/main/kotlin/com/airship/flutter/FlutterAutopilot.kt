package com.airship.flutter

import android.content.Context
import android.util.Log
import com.airship.flutter.AirshipBackgroundExecutor
import com.urbanairship.UAirship
import com.urbanairship.analytics.Analytics
import com.urbanairship.android.framework.proxy.BaseAutopilot
import com.urbanairship.android.framework.proxy.ProxyStore

import androidx.annotation.NonNull
import androidx.core.app.NotificationCompat
import com.urbanairship.Autopilot
import com.urbanairship.messagecenter.MessageCenter
import com.urbanairship.push.*
import com.urbanairship.push.notifications.AirshipNotificationProvider
import com.urbanairship.push.notifications.NotificationArguments
import androidx.annotation.XmlRes
import com.airship.flutter.AirshipBackgroundExecutor.Companion.handleBackgroundMessage
import com.airship.flutter.events.Event
import com.airship.flutter.events.InboxUpdatedEvent
import com.airship.flutter.events.NotificationResponseEvent
import com.airship.flutter.events.PushReceivedEvent
import com.urbanairship.AirshipConfigOptions
import com.urbanairship.UAirship.getApplicationContext
import com.urbanairship.channel.AirshipChannelListener
import com.urbanairship.preferencecenter.PreferenceCenter
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.runBlocking

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

        // Register a listener for inbox update event
        MessageCenter.shared().inbox.addListener {
            EventManager.shared.notifyEvent(InboxUpdatedEvent())
        }

        airship.pushManager.addPushListener{ message, notificationPosted ->
            if (notificationPosted) return@addPushListener

            if (!appContext.isAppInForeground()) {
                handleBackgroundMessage(appContext, message.toJsonValue().optMap().map)
            }

            post(PushReceivedEvent(message))
        }

        airship.analytics.registerSDKExtension(Analytics.EXTENSION_FLUTTER, AirshipPluginVersion.AIRSHIP_PLUGIN_VERSION);
        airship.pushManager.notificationListener = object : NotificationListener {
            override fun onNotificationPosted(@NonNull notificationInfo: NotificationInfo) {
                if (!appContext.isAppInForeground()) {
                    handleBackgroundMessage(appContext, notificationInfo.message.toJsonValue().optMap().map)
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
    }

    private fun post(event: Event) = EventManager.shared.notifyEvent(event)

    override fun onMigrateData(context: Context, proxyStore: ProxyStore) {
        // TODO
    }
}
