/* Copyright Airship and Contributors */

package com.airship.flutter

import android.content.Context
import android.view.View
import android.view.ViewGroup
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
    selfSizing: Boolean
) : PlatformView, MethodChannel.MethodCallHandler {

    // Stable view handed to Flutter. The container inside it is rebuilt when the
    // sizing mode changes, so the view Flutter holds never has to be replaced.
    private val root = FrameLayout(context)

    private val airshipEmbeddedView = AirshipEmbeddedView(context, embeddedId, selection = selection)
    private val density: Float = context.resources.displayMetrics.density
    private var reportedHeight: Double = -1.0
    private var selfSizing: Boolean = selfSizing

    private val layoutChangeListener =
        View.OnLayoutChangeListener { view, _, _, _, _, _, _, _, _ ->
            reportContentHeight(view.measuredHeight / density.toDouble())
        }

    init {
        root.layoutParams = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT
        )
        applyContainer()
        channel.setMethodCallHandler(this)
    }

    // Rebuilds the hierarchy for the current mode. Self sizing hosts the content in
    // a scroll view so it measures against an unconstrained height; measurement and
    // the display-based percent fallback apply only in that mode.
    private fun applyContainer() {
        (airshipEmbeddedView.parent as? ViewGroup)?.removeView(airshipEmbeddedView)
        root.removeAllViews()
        airshipEmbeddedView.removeOnLayoutChangeListener(layoutChangeListener)

        airshipEmbeddedView.layoutParams = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            if (selfSizing) {
                FrameLayout.LayoutParams.WRAP_CONTENT
            } else {
                FrameLayout.LayoutParams.MATCH_PARENT
            }
        )

        if (selfSizing) {
            airshipEmbeddedView.parentHeightProvider = {
                context.resources.displayMetrics.heightPixels
            }
            airshipEmbeddedView.addOnLayoutChangeListener(layoutChangeListener)

            val scrollView = ScrollView(context).apply {
                isVerticalScrollBarEnabled = false
                layoutParams = FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.MATCH_PARENT,
                    FrameLayout.LayoutParams.MATCH_PARENT
                )
            }
            scrollView.addView(airshipEmbeddedView)
            root.addView(scrollView)
        } else {
            // Percent content must resolve against the box Flutter gives us here.
            airshipEmbeddedView.parentHeightProvider = null
            root.addView(airshipEmbeddedView)
        }
    }

    private fun setSelfSizing(value: Boolean) {
        if (selfSizing == value) return
        selfSizing = value
        // The next report is against a different measurement, so don't suppress it.
        reportedHeight = -1.0
        applyContainer()
    }

    private fun reportContentHeight(height: Double) {
        if (abs(height - reportedHeight) <= 0.5) return
        reportedHeight = height
        channel.invokeMethod("onSizeUpdate", mapOf("height" to height))
    }

    override fun getView(): View = root

    override fun dispose() {
        airshipEmbeddedView.removeOnLayoutChangeListener(layoutChangeListener)
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "setSizeToContent" -> {
                setSelfSizing(call.argument<Boolean>("sizeToContent") ?: false)
                result.success(null)
            }
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
        val selfSizing = params?.get("sizeToContent") as? Boolean ?: false

        return FlutterEmbeddedView(checkNotNull(context), channel, embeddedId, selection, selfSizing)
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
