package com.airship.flutter

import android.content.Context
import android.graphics.Bitmap
import android.view.View
import android.webkit.WebView
import com.urbanairship.UAirship
import com.urbanairship.messagecenter.MessageCenter
import com.urbanairship.messagecenter.webkit.MessageWebView
import com.urbanairship.messagecenter.webkit.MessageWebViewClient
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformViewFactory

class FlutterInboxMessageView(
    private var context: Context,
    channel: MethodChannel
) : PlatformView, MethodChannel.MethodCallHandler {

    private lateinit var webviewResult: MethodChannel.Result

    private val webView: MessageWebView by lazy {
        val view = MessageWebView(context)
        view.webViewClient = object : MessageWebViewClient() {
            override fun onPageStarted(view: WebView, url: String?, favicon: Bitmap?) {
                super.onPageStarted(view, url, favicon)
                channel.invokeMethod("onLoadStarted", null)
            }

            override fun onPageFinished(view: WebView?, url: String?) {
                super.onPageFinished(view, url)
                channel.invokeMethod("onLoadFinished", null)
            }

            override fun onClose(webView: WebView) {
                super.onClose(webView)
                channel.invokeMethod("onClose", null)
            }

            @Deprecated("Deprecated in Java")
            override fun onReceivedError(view: WebView?, errorCode: Int, description: String?, failingUrl: String?) {
                super.onReceivedError(view, errorCode, description, failingUrl)
                if (errorCode == 410) {
                    webviewResult.error("InvalidMessage", "Unable to load message", "Message not available")
                } else {
                    webviewResult.error("InvalidMessage", "Unable to load message", "Message load failed")
                }
            }
        }
        view
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "loadMessage" -> loadMessage(call, result)
            else -> result.notImplemented()
        }
    }

    override fun getView(): View = webView

    override fun dispose() {

    }

    private fun loadMessage(call: MethodCall, result: MethodChannel.Result) {
        webviewResult = result
        if (!(UAirship.isTakingOff() || UAirship.isFlying())) {
            result.error("AIRSHIP_GROUNDED", "Takeoff not called.", null)
            return
        }

        val message = MessageCenter.shared().inbox.getMessage(call.arguments())
        if (message != null) {
            webView.loadMessage(message)
            message.markRead()
        } else {
            result.error("InvalidMessage", "Unable to load message: ${call.arguments}", null)
        }
    }
}

class InboxMessageViewFactor(
    private val binaryMessenger: BinaryMessenger
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        val channel = MethodChannel(binaryMessenger, "com.airship.flutter/InboxMessageView_$viewId")
        val view = FlutterInboxMessageView(checkNotNull(context), channel)
        channel.setMethodCallHandler(view)
        return view
    }
}