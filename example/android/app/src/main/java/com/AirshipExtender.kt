package com.urbanairship.sample

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.annotation.Keep
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.urbanairship.UAirship
import com.urbanairship.android.framework.proxy.AirshipPluginExtender
import com.urbanairship.json.requireField
import com.urbanairship.liveupdate.LiveUpdate
import com.urbanairship.liveupdate.LiveUpdateEvent
import com.urbanairship.liveupdate.LiveUpdateManager
import com.urbanairship.liveupdate.LiveUpdateResult
import com.urbanairship.liveupdate.SuspendLiveUpdateNotificationHandler
import com.urbanairship.sample.R
import android.view.View
import android.widget.FrameLayout
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import androidx.appcompat.app.AppCompatActivity
import com.urbanairship.android.layout.AirshipCustomViewManager
import io.flutter.embedding.android.FlutterFragment
import com.urbanairship.android.layout.AirshipCustomViewHandler
import com.urbanairship.android.layout.AirshipCustomViewArguments
import io.flutter.embedding.android.FlutterActivity
import android.util.Log
import io.flutter.embedding.android.FlutterSurfaceView
import io.flutter.embedding.android.FlutterTextureView
import io.flutter.view.FlutterMain
import io.flutter.embedding.engine.renderer.FlutterUiDisplayListener


@Keep
public final class AirshipExtender: AirshipPluginExtender {
    override fun onAirshipReady(context: Context, airship: UAirship) {
        LiveUpdateManager.shared().register("Example", ExampleLiveUpdateHandler())

        // Register custom views
        AirshipCustomViewManager.register("amc-view", FlutterCustomViewHandler())
    }
}

// Handler for Flutter custom views
class FlutterCustomViewHandler : AirshipCustomViewHandler {
    override fun onCreateView(context: Context, args: AirshipCustomViewArguments): View {
        return FlutterCustomView(
            context,
            args.name,
            args.properties
        )
    }
}

// Flutter custom view that embeds a Flutter widget
class FlutterCustomView(
    context: Context,
    private val viewName: String,
    private val properties: com.urbanairship.json.JsonMap
) : FrameLayout(context) {

    private var flutterEngine: FlutterEngine? = null
    private var flutterView: FlutterView? = null
    private var isEngineInitialized = false

    companion object {
        private const val TAG = "FlutterCustomView"
    }

    init {
        setupView()
    }

    private fun setupView() {
        // Set background color to black to match iOS
        setBackgroundColor(android.graphics.Color.BLACK)

        // Set layout params if not already set
        if (layoutParams == null) {
            layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT)
        }
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        embedFlutterView()
    }

    private fun embedFlutterView() {
        if (isEngineInitialized) {
            return
        }

        try {
            val route = "/custom/$viewName"

            // Create a new Flutter engine
            flutterEngine = FlutterEngine(context).apply {
                // Set initial route BEFORE starting the engine
                navigationChannel.setInitialRoute(route)

                // Start executing Dart code
                dartExecutor.executeDartEntrypoint(
                    DartExecutor.DartEntrypoint.createDefault()
                )
            }

            // Create Flutter view - TextureView provides better performance for embedded views
            val renderSurface = FlutterTextureView(context)
            flutterView = FlutterView(context, renderSurface)

            // Add Flutter view to this container
            val params = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT)
            addView(flutterView, params)

            // Attach Flutter view to engine
            flutterView?.attachToFlutterEngine(flutterEngine!!)

            // Notify Flutter of the lifecycle state
            flutterEngine?.lifecycleChannel?.appIsResumed()

            isEngineInitialized = true

        } catch (e: Exception) {
            Log.e(TAG, "Failed to create Flutter view", e)
            cleanup()
        }
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        cleanup()
    }

    override fun onWindowVisibilityChanged(visibility: Int) {
        super.onWindowVisibilityChanged(visibility)

        // Handle lifecycle based on visibility
        when (visibility) {
            View.VISIBLE -> {
                flutterEngine?.lifecycleChannel?.appIsResumed()
            }
            View.INVISIBLE, View.GONE -> {
                flutterEngine?.lifecycleChannel?.appIsPaused()
            }
        }
    }

    private fun cleanup() {
        try {
            // Notify Flutter the app is being paused
            flutterEngine?.lifecycleChannel?.appIsPaused()

            // Detach and remove the Flutter view
            flutterView?.let { view ->
                view.detachFromFlutterEngine()
                removeView(view)
            }
            flutterView = null

            // Destroy the Flutter engine
            flutterEngine?.destroy()
            flutterEngine = null

            isEngineInitialized = false

        } catch (e: Exception) {
            Log.e(TAG, "Error during cleanup", e)
        }
    }

    // Pass properties to Flutter if needed
    fun updateProperties(newProperties: com.urbanairship.json.JsonMap) {
        // This could be implemented to send properties to Flutter via MethodChannel
        // For now, properties are only used during initialization
    }
}

public final class ExampleLiveUpdateHandler: SuspendLiveUpdateNotificationHandler() {
    override suspend fun onUpdate(
        context: Context,
        event: LiveUpdateEvent,
        update: LiveUpdate
    ): LiveUpdateResult<NotificationCompat.Builder> {

        if (event == LiveUpdateEvent.END) {
            // Dismiss the live update on END. The default behavior will leave the Live Update
            // in the notification tray until the dismissal time is reached or the user dismisses it.
            return LiveUpdateResult.cancel()
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val importance = NotificationManager.IMPORTANCE_DEFAULT
            val channel = NotificationChannel("emoji-example", "Emoji example", importance)
            channel.description = "Emoji example"
            NotificationManagerCompat.from(context).createNotificationChannel(channel)
        }

        val launchIntent = context.packageManager
            .getLaunchIntentForPackage(context.packageName)
            ?.addCategory(update.name)
            ?.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            ?.setPackage(null)

        val contentIntent = PendingIntent.getActivity(
            context, 0, launchIntent, PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(context, "emoji-example")
            .setSmallIcon(R.drawable.ic_notification)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_EVENT)
            .setContentTitle("Example Live Update")
            .setContentText(update.content.requireField<String>("emoji"))
            .setContentIntent(contentIntent)

        return LiveUpdateResult.ok(notification)
    }
}