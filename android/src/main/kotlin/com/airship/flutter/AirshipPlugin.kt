package com.airship.flutter

import android.content.Context
import android.view.View
import com.urbanairship.UAirship
import com.urbanairship.analytics.CustomEvent
import com.urbanairship.json.JsonMap
import com.urbanairship.json.JsonValue
import com.urbanairship.util.DateUtils
import com.urbanairship.widget.UAWebView
import com.urbanairship.widget.UAWebViewClient
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory


class InboxMessageViewFactory(private val registrar: Registrar) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, arguments: Any?): PlatformView {
        val view = FlutterInboxMessageView(context)
        val channel = MethodChannel(registrar.messenger(), "com.airship.flutter/InboxMessageView_$viewId")
        channel.setMethodCallHandler(view)
        return view
    }
}

class FlutterInboxMessageView(private var context: Context) : PlatformView, MethodCallHandler {

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
            EventManager.shared.register(registrar)
            registrar.platformViewRegistry().registerViewFactory("com.airship.flutter/InboxMessageView", InboxMessageViewFactory(registrar))
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getChannelId" -> getChannelId(result)
            "setUserNotificationsEnabled" -> setUserNotificationsEnabled(call, result)
            "getUserNotificationsEnabled" -> getUserNotificationsEnabled(result)
            "addTags" -> addTags(call, result)
            "addEvent" -> addEvent(call, result)
            "removeTags" -> removeTags(call, result)
            "getTags" -> getTags(result)
            "setNamedUser" -> setNamedUser(call, result)
            "getNamedUser" -> getNamedUser(result)
            "getInboxMessages" -> getInboxMessages(result)
            "markInboxMessageRead" -> markInboxMessageRead(call, result)
            "deleteInboxMessage" -> deleteInboxMessage(call, result)
            else -> result.notImplemented()
        }
    }

    private fun getInboxMessages(result: Result) {
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
                                    putOpt("expiration_date", DateUtils.createIso8601TimeStamp(message.expirationDateMS!!))
                                }
                            }.build().toString()
                }

        result.success(messages)
    }

    private fun markInboxMessageRead(call: MethodCall, result: Result) {
        val messageId = call.arguments as String?
        UAirship.shared().inbox.markMessagesRead(setOf(messageId))
        result.success(null)
    }

    private fun deleteInboxMessage(call: MethodCall, result: Result) {
        val messageId = call.arguments as String?
        UAirship.shared().inbox.deleteMessages(setOf(messageId))
        result.success(null)
    }

    private fun addTags(call: MethodCall, result: Result) {
        val tags = uncheckedCast<List<String>>(call.arguments).toSet()
        UAirship.shared().pushManager.editTags().addTags(tags).apply()
        result.success(null)
    }

    private fun addEvent(call: MethodCall, result: Result) {
        val eventMap = call.arguments as HashMap<*, *>

        val eventName = eventMap[CustomEvent.EVENT_NAME] as String? ?: run {
            result.success(false)
            return
        }

        CustomEvent.Builder(eventName).let {
            val eventVal = (eventMap[CustomEvent.EVENT_VALUE] as Int?)
            if (eventVal != null) {
                it.setEventValue(eventVal)
            }

            val properties = eventMap[CustomEvent.PROPERTIES] as HashMap<String, Any>?
            if (properties != null) {
                parseProperties(properties, it)
            }

            val transactionId = eventMap[CustomEvent.TRANSACTION_ID] as String?
            if (transactionId != null) {
                it.setTransactionId(transactionId)
            }

            val interactionId = eventMap[CustomEvent.INTERACTION_ID] as String?
            val interactionType = eventMap[CustomEvent.INTERACTION_TYPE] as String?

            if (interactionId != null && interactionType != null) {
                it.setInteraction(interactionType, interactionId)
            }

            val event = it.build()
            if (event.isValid) {
                event.track()
                result.success(true)
            } else {
                result.success(false)
            }
        }
    }

    private fun parseProperties(map:HashMap<String, Any>, builder:CustomEvent.Builder) {
        for ((key, value) in map) {
            if (value is Int) {
                builder.addProperty(key, value)
                continue
            }

            if (value is Boolean) {
                builder.addProperty(key, value)
                continue
            }

            if (value is String) {
                builder.addProperty(key, value)
                continue
            }

            if (value is Collection<*>) {
                value.filterIsInstance<String>().let {
                    builder.addProperty(key, it)
                }
                continue
            }
        }
    }

    private fun removeTags(call: MethodCall, result: Result) {
        val tags = uncheckedCast<List<String>>(call.arguments).toSet()
        UAirship.shared().pushManager.editTags().removeTags(tags).apply()
        result.success(null)
    }

    private fun getTags(result: Result) {
        result.success(ArrayList<String>(UAirship.shared().pushManager.tags))
    }

    private fun setNamedUser(call: MethodCall, result: Result) {
        UAirship.shared().namedUser.id = call.arguments as String?
        result.success(null)
    }

    private fun getNamedUser(result: Result) {
        result.success(UAirship.shared().namedUser.id)
    }

    private fun setUserNotificationsEnabled(call: MethodCall, result: Result) {
        UAirship.shared().pushManager.userNotificationsEnabled = call.arguments as Boolean
        result.success(true)
    }

    private fun getUserNotificationsEnabled(result: Result) {
        result.success(UAirship.shared().pushManager.userNotificationsEnabled)
    }

    fun getChannelId(result: Result) {
        result.success(UAirship.shared().pushManager.channelId)
    }

    @Suppress("UNCHECKED_CAST")
    fun <T> uncheckedCast(value: Any): T {
        return value as T
    }
}
