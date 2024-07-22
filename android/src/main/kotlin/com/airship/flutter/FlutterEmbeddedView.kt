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