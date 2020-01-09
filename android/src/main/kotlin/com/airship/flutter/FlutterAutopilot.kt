package com.airship.flutter

import android.util.Log
import android.content.Context
import androidx.annotation.NonNull
import androidx.core.app.NotificationCompat
import com.airship.flutter.events.*
import com.urbanairship.Autopilot
import com.urbanairship.UAirship
import com.urbanairship.actions.*
import com.urbanairship.messagecenter.MessageCenter
import com.urbanairship.push.*
import com.urbanairship.push.notifications.AirshipNotificationProvider
import com.urbanairship.push.notifications.NotificationArguments
import androidx.annotation.XmlRes
import com.urbanairship.channel.AirshipChannelListener

const val PUSH_MESSAGE_BUNDLE_EXTRA = "com.urbanairship.push_bundle"

class FlutterAutopilot : Autopilot() {
    override fun onAirshipReady(airship: UAirship) {
        super.onAirshipReady(airship)

        Log.i("FlutterAutopilot", "onAirshipReady")

        // Register a listener for inbox update event
        airship.inbox.addListener {
            EventManager.shared.notifyEvent(InboxUpdatedEvent())
        }

        airship.pushManager.notificationProvider = object : AirshipNotificationProvider(UAirship.getApplicationContext(), airship.airshipConfigOptions) {
            override fun onExtendBuilder(context: Context, builder: NotificationCompat.Builder, arguments: NotificationArguments): NotificationCompat.Builder {
                builder.extras.putBundle(PUSH_MESSAGE_BUNDLE_EXTRA, arguments.message.pushBundle)
                return super.onExtendBuilder(context, builder, arguments)
            }
        }

        airship.pushManager.addPushListener{ message, notificationPosted ->
            if (!notificationPosted) {
                post(PushReceivedEvent(message))
            }
        }

        airship.pushManager.setNotificationListener(object : NotificationListener {
            override fun onNotificationPosted(@NonNull notificationInfo: NotificationInfo) {
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
        })

        airship.channel.addChannelListener(object : AirshipChannelListener {
            override fun onChannelCreated(channelId: String) {
                post(ChannelRegistrationEvent(channelId, UAirship.shared().pushManager.pushToken))
            }

            override fun onChannelUpdated(channelId: String) {
                post(ChannelRegistrationEvent(channelId, UAirship.shared().pushManager.pushToken))
            }
        })

        airship.messageCenter.setOnShowMessageCenterListener(object : MessageCenter.OnShowMessageCenterListener {
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

        loadCustomNotificationChannels(UAirship.getApplicationContext(), airship)
        loadCustomNotificationButtonGroups(UAirship.getApplicationContext(), airship)
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
}