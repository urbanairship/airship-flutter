package com.airship.flutter

import android.content.Context
import android.view.ContextThemeWrapper
import android.view.View
import com.airship.airship.R
import com.urbanairship.Airship
import com.urbanairship.messagecenter.Message
import com.urbanairship.messagecenter.ui.view.MessageView
import com.urbanairship.messagecenter.ui.view.MessageViewModel
import com.urbanairship.messagecenter.ui.view.MessageViewState
import com.urbanairship.messagecenter.ui.view.bind

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformViewFactory
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.plus

class FlutterInboxMessageView(
    context: Context,
    channel: MethodChannel
) : PlatformView, MethodChannel.MethodCallHandler {

    private val viewModel = MessageViewModel()
    private val messageView: MessageView = MessageView(
        ContextThemeWrapper(context, R.style.FlutterAirshipMessageViewTheme)
    )
    private val scope: CoroutineScope = CoroutineScope(Dispatchers.Main.immediate) + SupervisorJob()
    private var currentMessageId: String? = null
    private lateinit var webviewResult: MethodChannel.Result

    init {
        messageView.listener = object : MessageView.Listener {
            override fun onMessageLoaded(message: Message) {
                viewModel.markMessagesRead(message)
                channel.invokeMethod("onLoadFinished", null)
            }

            override fun onMessageLoadError(error: MessageViewState.Error.Type) {
                val details = when (error) {
                    MessageViewState.Error.Type.LOAD_FAILED -> "Message load failed"
                    MessageViewState.Error.Type.UNAVAILABLE -> "Message not available"
                }
                webviewResult.error("InvalidMessage", "Unable to load message", details)
            }

            override fun onRetryClicked() {
                currentMessageId?.let { viewModel.loadMessage(it) }
            }

            override fun onCloseMessage() {
                channel.invokeMethod("onClose", null)
            }
        }

        @Suppress("RestrictedApi")
        messageView.bind(viewModel, scope)

        scope.launch {
            viewModel.states.collect { state ->
                if (state is MessageViewState.Loading) {
                    channel.invokeMethod("onLoadStarted", null)
                }
            }
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "loadMessage" -> loadMessage(call, result)
            else -> result.notImplemented()
        }
    }

    override fun getView(): View = messageView

    override fun dispose() {
        scope.cancel()
    }

    private fun loadMessage(call: MethodCall, result: MethodChannel.Result) {
        webviewResult = result
        if (!(Airship.isTakingOff || Airship.isFlying)) {
            result.error("AIRSHIP_GROUNDED", "Takeoff not called.", null)
            return
        }

        val messageId = call.arguments<String>() ?: run {
            result.error("InvalidArgument", "Must be a message ID", null)
            return
        }
        currentMessageId = messageId
        viewModel.loadMessage(messageId)
    }
}

class InboxMessageViewFactory(
    private val binaryMessenger: BinaryMessenger
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        val channel = MethodChannel(binaryMessenger, "com.airship.flutter/InboxMessageView_$viewId")
        val view = FlutterInboxMessageView(checkNotNull(context), channel)
        channel.setMethodCallHandler(view)
        return view
    }
}