package com.airship.flutter

import android.graphics.Color
import android.widget.TextView
import android.content.Context
import android.view.View
import android.widget.FrameLayout
import com.urbanairship.UAirship
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import com.urbanairship.embedded.AirshipEmbeddedView
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class FlutterEmbeddedView(
    private var context: Context,
    channel: MethodChannel,
    private val embeddedId: String
) : PlatformView, MethodChannel.MethodCallHandler {

    override fun getView(): View {
        return AirshipEmbeddedView(context, embeddedId)
    }
    override fun dispose() {}
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        // Handle method calls if needed
    }
}


class EmbeddedViewFactory(private val binaryMessenger: BinaryMessenger) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        val channel = MethodChannel(binaryMessenger, "com.airship.flutter/EmbeddedView_$viewId")

        // Extracting embeddedId from args
        val params = args as? Map<String, Any>
        val embeddedId = params?.get("embeddedId") as? String ?: "defaultId"

        val view = FlutterEmbeddedView(checkNotNull(context), channel, embeddedId)
        return view
    }
}