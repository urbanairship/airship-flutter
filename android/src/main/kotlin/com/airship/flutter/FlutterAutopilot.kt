package com.airship.flutter

import androidx.annotation.NonNull
import com.urbanairship.Autopilot
import com.urbanairship.UAirship
import com.airship.flutter.events.*
import com.urbanairship.actions.*
import com.urbanairship.messagecenter.MessageCenter
import com.urbanairship.push.*


class FlutterAutopilot : Autopilot() {

    override fun onAirshipReady(airship: UAirship) {
        super.onAirshipReady(airship)

        // Register a listener for inbox update event
        airship.inbox.addListener {
            EventManager.shared.notifyEvent(InboxUpdatedEvent())
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

        airship.pushManager.addRegistrationListener(object : RegistrationListener {
            override fun onChannelCreated(channelId: String) {
                post(ChannelRegistrationEvent(channelId, UAirship.shared().pushManager.registrationToken))
            }

            override fun onChannelUpdated(channelId: String) {
                post(ChannelRegistrationEvent(channelId, UAirship.shared().pushManager.registrationToken))
            }

            override fun onPushTokenUpdated(pushToken: String) {}
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

        airship.deepLinkListener = object : DeepLinkListener {
            override fun onDeepLink(deepLink: String): Boolean {
                EventManager.shared.notifyEvent(DeepLinkEvent(deepLink))
                return true
            }
        }
    }

    private fun post(event: Event) = EventManager.shared.notifyEvent(event)
}