package com.airship.flutter

import android.content.Context

import com.urbanairship.AirshipReceiver
import com.urbanairship.json.JsonValue
import com.urbanairship.push.PushMessage

class FlutterAirshipReceiver : AirshipReceiver() {

    override fun onPushReceived(context: Context, message: PushMessage, notificationPosted: Boolean) {
        super.onPushReceived(context, message, notificationPosted)
        EventManager.shared.notifyEvent(EventType.PUSH_RECEIVED, message)
    }

    override fun onChannelCreated(context: Context, channelId: String) {
        super.onChannelCreated(context, channelId)
        EventManager.shared.notifyEvent(EventType.CHANNEL_CREATED, JsonValue.wrap(channelId))
    }

    override fun onChannelUpdated(context: Context, channelId: String) {
        super.onChannelUpdated(context, channelId)
        EventManager.shared.notifyEvent(EventType.CHANNEL_UPDATED, JsonValue.wrap(channelId))
    }
}
