package com.airship.flutter

import android.app.Activity
import android.content.Context
import com.urbanairship.actions.ActionResult
import com.urbanairship.android.framework.proxy.EventType
import com.urbanairship.android.framework.proxy.events.EventEmitter
import com.urbanairship.android.framework.proxy.proxies.AirshipProxy
import com.urbanairship.json.JsonValue
import io.flutter.embedding.engine.FlutterShellArgs
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.plugin.platform.PlatformViewRegistry
import kotlinx.coroutines.*

class AirshipPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel

    private lateinit var context: Context

    private val scope: CoroutineScope = CoroutineScope(Dispatchers.Main) + SupervisorJob()

    private var mainActivity: Activity? = null

    private lateinit var streams : Map<EventType, AirshipEventStream>

    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val plugin = AirshipPlugin()
            plugin.register(registrar.context().applicationContext, registrar.messenger(), registrar.platformViewRegistry())
        }

        internal const val AIRSHIP_SHARED_PREFS = "com.urbanairship.flutter"
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        register(binding.applicationContext, binding.binaryMessenger, binding.platformViewRegistry)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun register(context: Context, binaryMessenger: BinaryMessenger, platformViewRegistry: PlatformViewRegistry) {
        this.context = context
        this.channel = MethodChannel(binaryMessenger, "com.airship.flutter/airship")
        this.channel.setMethodCallHandler(this)

        this.streams = EventType.values().associateWith {
            AirshipEventStream(it, binaryMessenger)
        }

        platformViewRegistry.registerViewFactory("com.airship.flutter/InboxMessageView", InboxMessageViewFactory(binaryMessenger))

        scope.launch {
            EventEmitter.shared().pendingEventListener.collect {
                streams[it.type]?.processPendingEvents()
            }
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        val proxy = AirshipProxy.shared(context)

        when (call.method) {
            // Flutter
            "startBackgroundIsolate" -> startBackgroundIsolate(call, result)

            // Airship
            "takeOff" -> result.resolveResult(call) { proxy.takeOff(call.jsonArgs()) }
            "isFlying" -> result.resolveResult(call) { proxy.isFlying() }

            // Channel
            "channel#getChannelId" -> result.resolveResult(call) { proxy.channel.getChannelId() }
            "channel#addTags" -> result.resolveResult(call) {
                call.stringList().forEach {
                    proxy.channel.addTag(it)
                }
            }
            "channel#removeTags" ->
                result.resolveResult(call) {
                    call.stringList().forEach {
                        proxy.channel.removeTag(it)
                    }
                }
            "channel#getTags" -> result.resolveResult(call) { proxy.channel.getTags().toList() }
            "channel#editTagGroups" -> result.resolveResult(call) { proxy.channel.editTagGroups(call.jsonArgs()) }
            "channel#editSubscriptionLists" -> result.resolveResult(call) { proxy.channel.editSubscriptionLists(call.jsonArgs()) }
            "channel#editAttributes" -> result.resolveResult(call) { proxy.channel.editAttributes(call.jsonArgs()) }
            "channel#getSubscriptionLists" -> result.resolvePending(call) { proxy.channel.getSubscriptionLists() }
            "channel#enableChannelCreation" -> result.resolveResult(call) { proxy.channel.enableChannelCreation() }

            // Contact
            "contact#reset" -> result.resolveResult(call) { proxy.contact.reset() }
            "contact#identify" -> result.resolveResult(call) { proxy.contact.identify(call.stringArg()) }
            "contact#getNamedUserId" -> result.resolveResult(call) { proxy.contact.getNamedUserId() }
            "contact#editTagGroups" -> result.resolveResult(call) { proxy.contact.editTagGroups(call.jsonArgs()) }
            "contact#editSubscriptionLists" -> result.resolveResult(call) { proxy.contact.editSubscriptionLists(call.jsonArgs()) }
            "contact#editAttributes" -> result.resolveResult(call) { proxy.contact.editAttributes(call.jsonArgs()) }
            "contact#getSubscriptionLists" -> result.resolvePending(call) { proxy.contact.getSubscriptionLists() }

            // Push
            "push#setUserNotificationsEnabled" -> result.resolveResult(call) { proxy.push.setUserNotificationsEnabled(call.booleanArg()) }
            "push#enableUserNotifications" -> result.resolvePending(call) { proxy.push.enableUserPushNotifications() }
            "push#isUserNotificationsEnabled" -> result.resolveResult(call) { proxy.push.isUserNotificationsEnabled() }
            "push#getNotificationStatus" -> result.resolveResult(call) { proxy.push.getNotificationStatus() }
            "push#getActiveNotifications" -> result.resolveResult(call) { proxy.push.getActiveNotifications() }
            "push#clearNotification" -> result.resolveResult(call) { proxy.push.clearNotification(call.stringArg()) }
            "push#clearNotifications" -> result.resolveResult(call) { proxy.push.clearNotifications() }
            "push#getRegistrationToken" -> result.resolveResult(call) { proxy.push.getRegistrationToken() }
            "push#android#isNotificationChannelEnabled" -> result.resolveResult(call) { proxy.push.isNotificationChannelEnabled(call.stringArg()) }
            "push#android#setNotificationConfig" -> result.resolveResult(call) { proxy.push.setNotificationConfig(call.jsonArgs()) }

            // In-App
            "inApp#setPaused" -> result.resolveResult(call) { proxy.inApp.setPaused(call.booleanArg()) }
            "inApp#isPaused" -> result.resolveResult(call) { proxy.inApp.isPaused() }
            "inApp#setDisplayInterval" -> result.resolveResult(call) { proxy.inApp.setDisplayInterval(call.longArg()) }
            "inApp#getDisplayInterval" -> result.resolveResult(call) { proxy.inApp.getDisplayInterval() }

            // Analytics
            "analytics#trackScreen" -> result.resolveResult(call) { proxy.analytics.trackScreen(call.optStringArg()) }
            "analytics#addEvent" -> result.resolveResult(call) { proxy.analytics.addEvent(call.jsonArgs())}
            "analytics#associateIdentifier" -> {
                val args = call.stringList()
                proxy.analytics.associateIdentifier(
                        args[0],
                        args.getOrNull(1)
                )
            }

            // Message Center
            "messageCenter#getMessages" -> result.resolveResult(call) { JsonValue.wrapOpt(proxy.messageCenter.getMessages()) }
            "messageCenter#display" -> result.resolveResult(call) { proxy.messageCenter.display(call.optStringArg()) }
            "messageCenter#markMessageRead" -> result.resolveResult(call) { proxy.messageCenter.markMessageRead(call.stringArg()) }
            "messageCenter#deleteMessage" -> result.resolveResult(call) { proxy.messageCenter.deleteMessage(call.stringArg()) }
            "messageCenter#getUnreadMessageCount" -> result.resolveResult(call) { proxy.messageCenter.getUnreadMessagesCount() }
            "messageCenter#setAutoLaunch" -> result.resolveResult(call) { proxy.messageCenter.setAutoLaunchDefaultMessageCenter(call.booleanArg()) }
            "messageCenter#refreshMessages" -> result.resolveDeferred(call) { callback ->
                proxy.messageCenter.refreshInbox().addResultCallback {
                    if (it == true) {
                        callback(null, null)
                    } else {
                        callback(null, Exception("Failed to refresh"))
                    }
                }
            }

            // Preference Center
            "preferenceCenter#display" -> result.resolveResult(call) { proxy.preferenceCenter.displayPreferenceCenter(call.stringArg()) }
            "preferenceCenter#getConfig" -> result.resolvePending(call) { proxy.preferenceCenter.getPreferenceCenterConfig(call.stringArg()) }
            "preferenceCenter#setAutoLaunch" -> result.resolveResult(call) {
                val args = call.jsonArgs().requireList()
                proxy.preferenceCenter.setAutoLaunchPreferenceCenter(
                        args.get(0).requireString(),
                        args.get(1).getBoolean(false)
                )
            }

            // Privacy Manager
            "privacyManager#setEnabledFeatures" -> result.resolveResult(call) { proxy.privacyManager.setEnabledFeatures(call.stringList()) }
            "privacyManager#getEnabledFeatures" -> result.resolveResult(call) { proxy.privacyManager.getFeatureNames() }
            "privacyManager#enableFeatures" -> result.resolveResult(call) { proxy.privacyManager.enableFeatures(call.stringList()) }
            "privacyManager#disableFeatures" -> result.resolveResult(call) { proxy.privacyManager.disableFeatures(call.stringList()) }
            "privacyManager#isFeaturesEnabled" -> result.resolveResult(call) { proxy.privacyManager.isFeatureEnabled(call.stringList()) }

            // Locale
            "locale#setLocaleOverride" -> result.resolveResult(call) { proxy.locale.setCurrentLocale(call.stringArg()) }
            "locale#getCurrentLocale" -> result.resolveResult(call) { proxy.locale.getCurrentLocale() }
            "locale#clearLocaleOverride" -> result.resolveResult(call) { proxy.locale.clearLocale() }

            // Actions
            "actions#run" -> result.resolveDeferred(call) { callback ->
                val args = call.jsonArgs().requireList().list

                proxy.actions.runAction(args[0].requireString(), args.getOrNull(1))
                        .addResultCallback { actionResult ->
                            if (actionResult != null && actionResult.status == ActionResult.STATUS_COMPLETED) {
                                callback(actionResult.value, null)
                            } else {
                                callback(null, Exception("Action failed ${actionResult?.status}"))
                            }
                        }
            }

            else -> result.notImplemented()
        }
    }

    private fun startBackgroundIsolate(call: MethodCall, result: Result) {
        val args = call.arguments as Map<*, *>
        val isolateCallback = args["isolateCallback"] as? Long ?: 0
        val messageCallback = args["messageCallback"] as? Long ?: 0
        val shellArgs = mainActivity?.intent?.let { FlutterShellArgs.fromIntent(it) }
        AirshipBackgroundExecutor.run {
            setCallbacks(context, isolateCallback, messageCallback)
            startIsolate(context, shellArgs)
        }
        result.success(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        mainActivity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        mainActivity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        mainActivity = binding.activity
    }

    override fun onDetachedFromActivity() {
        mainActivity = null
    }

    internal class AirshipEventStream(private val eventType: EventType, binaryMessenger: BinaryMessenger) {

        private var eventSink: EventChannel.EventSink? = null

        init {
            val name = when(eventType) {
                EventType.BACKGROUND_NOTIFICATION_RESPONSE_RECEIVED -> "com.airship.flutter/event/notification_response"
                EventType.FOREGROUND_NOTIFICATION_RESPONSE_RECEIVED -> "com.airship.flutter/event/notification_response"
                EventType.CHANNEL_CREATED -> "com.airship.flutter/event/channel_created"
                EventType.DEEP_LINK_RECEIVED -> "com.airship.flutter/event/deep_link_received"
                EventType.DISPLAY_MESSAGE_CENTER -> "com.airship.flutter/event/display_message_center"
                EventType.DISPLAY_PREFERENCE_CENTER -> "com.airship.flutter/event/display_preference_center"
                EventType.MESSAGE_CENTER_UPDATED -> "com.airship.flutter/event/message_center_updated"
                EventType.PUSH_TOKEN_RECEIVED -> "com.airship.flutter/event/push_token_received"
                EventType.FOREGROUND_PUSH_RECEIVED -> "com.airship.flutter/event/foreground_push_received"
                EventType.BACKGROUND_PUSH_RECEIVED -> "com.airship.flutter/event/background_push_received"
                EventType.NOTIFICATION_STATUS_CHANGED -> "com.airship.flutter/event/notification_status_changed"
            }

            val eventChannel = EventChannel(binaryMessenger, name)
            eventChannel.setStreamHandler(object:EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink?) {
                    this@AirshipEventStream.eventSink = eventSink
                    processPendingEvents()
                }

                override fun onCancel(p0: Any?) {
                    this@AirshipEventStream.eventSink = null
                }
            })
        }

        fun processPendingEvents() {
            val sink = eventSink ?: return

            EventEmitter.shared().processPending(listOf(eventType)) { event ->
                sink.success(event.body.unwrap())
                true
            }
        }
    }
}

