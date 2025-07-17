package com.urbanairship.sample

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.view.View
import android.widget.FrameLayout
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
import com.airbnb.lottie.LottieAnimationView
import com.airbnb.lottie.LottieDrawable
import com.urbanairship.android.layout.AirshipCustomViewArguments
import com.urbanairship.android.layout.AirshipCustomViewHandler
import com.urbanairship.android.layout.AirshipCustomViewManager

@Keep
public final class AirshipExtender: AirshipPluginExtender {
    override fun onAirshipReady(context: Context, airship: UAirship) {
        LiveUpdateManager.shared().register("Example", ExampleLiveUpdateHandler())

        // Register native Lottie view
        AirshipCustomViewManager.register("lottie-view", object : AirshipCustomViewHandler {
            override fun onCreateView(context: Context, args: AirshipCustomViewArguments): View {
                return LottieAnimationView(context).apply {
                    // Get animation URL from properties
                    val animationUrl = args.properties.get("animationUrl")?.string

                    // Set background color
                    setBackgroundColor(android.graphics.Color.BLACK)

                    // Load and play animation
                    if (!animationUrl.isNullOrEmpty()) {
                        setAnimationFromUrl(animationUrl)
                        repeatCount = LottieDrawable.INFINITE
                        playAnimation()
                    }

                    // Set layout params
                    layoutParams = FrameLayout.LayoutParams(
                        FrameLayout.LayoutParams.MATCH_PARENT,
                        FrameLayout.LayoutParams.MATCH_PARENT
                    )
                }
            }
        })
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