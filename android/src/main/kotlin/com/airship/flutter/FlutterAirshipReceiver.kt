package com.airship.flutter

import android.content.Context
import com.airship.flutter.events.*
import com.urbanairship.AirshipReceiver
import com.urbanairship.UAirship
import com.urbanairship.push.PushMessage

class FlutterAirshipReceiver : AirshipReceiver() {

    override fun onPushReceived(context: Context, message: PushMessage, notificationPosted: Boolean) {
        if (!notificationPosted) {
            post(PushReceivedEvent(message))
        }
    }

    override fun onNotificationPosted(context: Context, notificationInfo: NotificationInfo) {
        post(PushReceivedEvent(notificationInfo.message, notificationInfo))
    }

    override fun onNotificationOpened(context: Context, notificationInfo: NotificationInfo): Boolean {
        post(NotificationResponseEvent(notificationInfo))
        return false
    }

    override fun onNotificationOpened(context: Context, notificationInfo: NotificationInfo, actionButtonInfo: ActionButtonInfo): Boolean {
        post(NotificationResponseEvent(notificationInfo, actionButtonInfo))
        return false
    }

    override fun onChannelCreated(context: Context, channelId: String) {
        super.onChannelCreated(context, channelId)
        post(ChannelCreatedEvent(channelId, UAirship.shared().pushManager.registrationToken))
    }

    override fun onChannelUpdated(context: Context, channelId: String) {
        super.onChannelUpdated(context, channelId)
        post(ChannelUpdatedEvent(channelId, UAirship.shared().pushManager.registrationToken))
    }

    private fun post(event: Event) = EventManager.shared.notifyEvent(event)
}
