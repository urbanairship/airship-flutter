package com.airship.flutter

import android.content.Context
import android.graphics.Color
import android.view.View
import android.widget.FrameLayout
import com.urbanairship.embedded.AirshipEmbeddedView
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class FlutterEmbeddedView(
    private var context: Context,
    private val channel: MethodChannel,
    private val embeddedId: String
) : PlatformView, MethodChannel.MethodCallHandler {

    private val frameLayout: FrameLayout = FrameLayout(context)
    private var airshipEmbeddedView: AirshipEmbeddedView? = null

    init {
        setupAirshipEmbeddedView()
        channel.setMethodCallHandler(this)
    }
    private fun setupAirshipEmbeddedView() {

        airshipEmbeddedView = AirshipEmbeddedView(context, embeddedId)
        airshipEmbeddedView?.layoutParams = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT
        )
        frameLayout.addView(airshipEmbeddedView)
    }

    override fun getView(): View {
        frameLayout.layoutParams = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT
        )
        return frameLayout
    }

    override fun dispose() {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            else -> {
                result.error("UNAVAILABLE", "Unknown method: ${call.method}", null)
            }
        }
    }
}

class EmbeddedViewFactory(
    private val binaryMessenger: BinaryMessenger
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        val channel = MethodChannel(binaryMessenger, "com.airship.flutter/EmbeddedView_$viewId")

        // Extracting embeddedId from args
        val params = args as? Map<String, Any>
        val embeddedId = params?.get("embeddedId") as? String ?: "defaultId"

        return FlutterEmbeddedView(checkNotNull(context), channel, embeddedId)
    }
}