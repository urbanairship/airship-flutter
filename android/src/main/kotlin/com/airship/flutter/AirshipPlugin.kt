package com.airship.flutter

import android.content.Context
import android.view.View
import com.urbanairship.UAirship
import com.urbanairship.json.JsonMap
import com.urbanairship.json.JsonValue
import com.urbanairship.util.DateUtils
import com.urbanairship.widget.UAWebView
import com.urbanairship.widget.UAWebViewClient
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import android.R.id



class InboxMessageViewFactory(private val registrar: Registrar) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, arguments: Any?): PlatformView {
        val view = FlutterInboxMessageView(context)
        val channel = MethodChannel(registrar.messenger(), "com.airship.flutter/InboxMessageView_$viewId")
        channel.setMethodCallHandler(view)
        return view
    }
}

class FlutterInboxMessageView(var context: Context) : PlatformView, MethodCallHandler {

    private val webView: UAWebView by lazy {
        val view = UAWebView(context)
        view.webViewClient = UAWebViewClient()
        view
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "loadMessage" -> loadMessage(call, result)
            else -> result.notImplemented()
        }
    }

    override fun getView(): View = webView

    override fun dispose() {

    }

    private fun loadMessage(call: MethodCall, result: Result) {
        val message = UAirship.shared().inbox.getMessage(call.arguments())
        if (message != null) {
            webView.loadRichPushMessage(message)
            message.markRead()
            result.success(true)
        } else {
            result.error("InvalidMessage", "Unable to load message: ${call.arguments}", null)
        }
    }
}

class AirshipPlugin : MethodCallHandler {

    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "com.airship.flutter/airship")
            channel.setMethodCallHandler(AirshipPlugin())
            val eventChannel = EventChannel(registrar.messenger(), "com.airship.flutter/airship_events")
            eventChannel.setStreamHandler(EventManager.shared)
            registrar.platformViewRegistry().registerViewFactory("com.airship.flutter/InboxMessageView", InboxMessageViewFactory(registrar))
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getChannelId" -> getChannelId(call, result)
            "setUserNotificationsEnabled" -> setUserNotificationsEnabled(call, result)
            "getUserNotificationsEnabled" -> getUserNotificationsEnabled(call, result)
            "addTags" -> addTags(call, result)
            "removeTags" -> removeTags(call, result)
            "getTags" -> getTags(call, result)
            "setNamedUser" -> setNamedUser(call, result)
            "getNamedUser" -> getNamedUser(call, result)
            "getInboxMessages" -> getInboxMessages(call, result)
            else -> result.notImplemented()
        }
    }

    private fun getInboxMessages(call: MethodCall, result: Result) {
        val messages = UAirship.shared().inbox.messages
                .map { message ->
                    val extras = message.extras.keySet().map { key ->
                        key to message.extras.getString(key)
                    }.toMap()

                    JsonMap.newBuilder()
                            .putOpt("title", message.title)
                            .putOpt("message_id", message.messageId)
                            .putOpt("sent_date", DateUtils.createIso8601TimeStamp(message.sentDateMS))
                            .putOpt("list_icon", message.listIconUrl)
                            .putOpt("is_read", message.isRead)
                            .putOpt("extras", JsonValue.wrap(extras))
                            .apply {
                                if (message.expirationDateMS != null) {
                                    putOpt("expiration_date", DateUtils.createIso8601TimeStamp(message.expirationDateMS))
                                }
                            }.build().toString()
                }

        result.success(messages)
    }

    private fun addTags(call: MethodCall, result: Result) {
        val tags = uncheckedCast<List<String>>(call.arguments).toSet()
        UAirship.shared().pushManager.editTags().addTags(tags).apply()
        result.success(null)
    }

    private fun removeTags(call: MethodCall, result: Result) {
        val tags = uncheckedCast<List<String>>(call.arguments).toSet()
        UAirship.shared().pushManager.editTags().removeTags(tags).apply()
        result.success(null)
    }

    private fun getTags(call: MethodCall, result: Result) {
        result.success(ArrayList<String>(UAirship.shared().pushManager.tags))
    }

    private fun setNamedUser(call: MethodCall, result: Result) {
        UAirship.shared().namedUser.id = call.arguments as String?
        result.success(null)
    }

    private fun getNamedUser(call: MethodCall, result: Result) {
        result.success(UAirship.shared().namedUser.id)
    }

    private fun setUserNotificationsEnabled(call: MethodCall, result: Result) {
        UAirship.shared().pushManager.userNotificationsEnabled = call.arguments as Boolean
        result.success(null)
    }

    private fun getUserNotificationsEnabled(call: MethodCall, result: Result) {
        result.success(UAirship.shared().pushManager.userNotificationsEnabled)
    }

    fun getChannelId(call: MethodCall, result: Result) {
        result.success(UAirship.shared().pushManager.channelId)
    }

    @Suppress("UNCHECKED_CAST")
    fun <T> uncheckedCast(value: Any): T {
        return value as T
    }
}

