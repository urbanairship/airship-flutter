/* Copyright Airship and Contributors */

package com.airship.flutter

import android.content.Context
import android.view.View
import android.widget.FrameLayout
import android.widget.ScrollView
import com.urbanairship.embedded.AirshipEmbeddedSelection
import com.urbanairship.embedded.AirshipEmbeddedView
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import kotlin.math.abs

class FlutterEmbeddedView(
    private val context: Context,
    private val channel: MethodChannel,
    private val embeddedId: String,
    private val selection: AirshipEmbeddedSelection,
    private val parentHeight: Double?
) : PlatformView, MethodChannel.MethodCallHandler {

    // Without an explicit height, the content is hosted in a scroll view so it measures
    // against an unconstrained height instead of the height Flutter imposes.
    private val selfSizing: Boolean = parentHeight == null

    private val container: FrameLayout = if (selfSizing) {
        ScrollView(context).apply {
            clipChildren = false
            isVerticalScrollBarEnabled = false
        }
    } else {
        FrameLayout(context)
    }

    private val airshipEmbeddedView = AirshipEmbeddedView(context, embeddedId, selection = selection)
    private val density: Float = context.resources.displayMetrics.density
    private var reportedHeight: Double = -1.0

    init {
        setupAirshipEmbeddedView()
        channel.setMethodCallHandler(this)
    }

    private fun setupAirshipEmbeddedView() {
        airshipEmbeddedView.layoutParams = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            if (selfSizing) {
                FrameLayout.LayoutParams.WRAP_CONTENT
            } else {
                FrameLayout.LayoutParams.MATCH_PARENT
            }
        )
        container.addView(airshipEmbeddedView)

        if (selfSizing) {
            // Percent sized content has no parent height to resolve against, so use the display.
            val displayHeight = context.resources.displayMetrics.heightPixels
            airshipEmbeddedView.parentHeightProvider = { displayHeight }

            airshipEmbeddedView.addOnLayoutChangeListener { view, _, _, _, _, _, _, _, _ ->
                reportContentHeight(view.measuredHeight / density.toDouble())
            }
        }
    }

    private fun reportContentHeight(height: Double) {
        if (abs(height - reportedHeight) <= 0.5) return
        reportedHeight = height
        channel.invokeMethod("onSizeUpdate", mapOf("height" to height))
    }

    override fun getView(): View {
        container.layoutParams = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT
        )
        return container
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

        val params = args as? Map<*, *>
        val embeddedId = params?.get("embeddedId") as? String ?: "defaultId"
        val selection = parseSelection(params?.get("selection") as? Map<*, *>)
        val parentHeight = (params?.get("parentHeight") as? Number)?.toDouble()

        return FlutterEmbeddedView(checkNotNull(context), channel, embeddedId, selection, parentHeight)
    }

    private fun parseSelection(selection: Map<*, *>?): AirshipEmbeddedSelection {
        val instanceId = selection?.get("instanceId") as? String
        return if (selection?.get("type") == "instance_id" && !instanceId.isNullOrEmpty()) {
            AirshipEmbeddedSelection.ByInstanceId(instanceId)
        } else {
            AirshipEmbeddedSelection.Priority
        }
    }
}
