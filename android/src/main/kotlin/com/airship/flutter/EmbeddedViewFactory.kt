package com.airship.flutter

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

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