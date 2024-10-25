package com.airship.flutter

import android.app.Activity
import android.content.Context
import android.os.Build
import android.util.Log
import com.urbanairship.actions.ActionResult
import com.urbanairship.android.framework.proxy.EventType
import com.urbanairship.android.framework.proxy.events.EventEmitter
import com.urbanairship.android.framework.proxy.proxies.AirshipProxy
import com.urbanairship.android.framework.proxy.proxies.FeatureFlagProxy
import com.urbanairship.android.framework.proxy.proxies.LiveUpdateRequest
import com.urbanairship.android.framework.proxy.proxies.EnableUserNotificationsArgs
import com.urbanairship.json.JsonValue
import com.urbanairship.json.toJsonList
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
import java.util.concurrent.locks.ReentrantLock
import kotlin.concurrent.withLock
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.filter
import kotlinx.coroutines.flow.filterNotNull
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map


class AirshipPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private val scope: CoroutineScope = CoroutineScope(Dispatchers.Main) + SupervisorJob()
    private var mainActivity: Activity? = null
    private lateinit var streams: Map<EventType, AirshipEventStream>

    companion object {
        @JvmStatic
        fun registerWith(
            // Registrar is deprecated, but still recommended in case consumers don't use v2 embedding
            // See: https://docs.flutter.dev/release/breaking-changes/plugin-api-migration#upgrade-steps
            @Suppress("DEPRECATION")
            registrar: Registrar
        ) {
            val plugin = AirshipPlugin()
            plugin.register(registrar.context().applicationContext, registrar.messenger(), registrar.platformViewRegistry())
        }

        internal const val AIRSHIP_SHARED_PREFS = "com.urbanairship.flutter"

        internal val EVENT_NAME_MAP = mapOf(
            EventType.BACKGROUND_NOTIFICATION_RESPONSE_RECEIVED to "com.airship.flutter/event/notification_response",
            EventType.FOREGROUND_NOTIFICATION_RESPONSE_RECEIVED to "com.airship.flutter/event/notification_response",
            EventType.CHANNEL_CREATED to "com.airship.flutter/event/channel_created",
            EventType.DEEP_LINK_RECEIVED to "com.airship.flutter/event/deep_link_received",
            EventType.DISPLAY_MESSAGE_CENTER to "com.airship.flutter/event/display_message_center",
            EventType.DISPLAY_PREFERENCE_CENTER to "com.airship.flutter/event/display_preference_center",
            EventType.MESSAGE_CENTER_UPDATED to "com.airship.flutter/event/message_center_updated",
            EventType.PUSH_TOKEN_RECEIVED to "com.airship.flutter/event/push_token_received",
            EventType.FOREGROUND_PUSH_RECEIVED to "com.airship.flutter/event/push_received",
            EventType.BACKGROUND_PUSH_RECEIVED to "com.airship.flutter/event/background_push_received",
            EventType.NOTIFICATION_STATUS_CHANGED to "com.airship.flutter/event/notification_status_changed",
            EventType.PENDING_EMBEDDED_UPDATED to "com.airship.flutter/event/pending_embedded_updated"
        )
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
        this.streams = generateEventStreams(binaryMessenger)

        platformViewRegistry.registerViewFactory("com.airship.flutter/InboxMessageView", InboxMessageViewFactory(binaryMessenger))
        platformViewRegistry.registerViewFactory("com.airship.flutter/EmbeddedView", EmbeddedViewFactory(binaryMessenger))

        scope.launch {
            EventEmitter.shared().pendingEventListener.collect {
                streams[it.type]?.processPendingEvents()
            }
        }
    }

    private fun generateEventStreams(binaryMessenger: BinaryMessenger): Map<EventType, AirshipEventStream> {
        // A single stream might map to multiple event types, create a map of the reverse index
        val streamGroups = mutableMapOf<String, MutableList<EventType>>()
        EVENT_NAME_MAP.forEach {
            streamGroups.getOrPut(it.value) { mutableListOf() }.add(it.key)
        }

        val streamMap = mutableMapOf<EventType, AirshipEventStream>()
        streamGroups.forEach { entry ->
            val stream = AirshipEventStream(entry.value, entry.key, binaryMessenger)
            stream.register() /// Set up handlers for each stream
            entry.value.forEach { type ->
                streamMap[type] = stream
            }
        }
        return streamMap
    }


    override fun onMethodCall(call: MethodCall, result: Result) {
        val proxy = AirshipProxy.shared(context)
        val coroutineScope = CoroutineScope(Dispatchers.Main + SupervisorJob())

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

            "channel#editTags" -> result.resolveResult(call) { proxy.channel.editTags(call.jsonArgs()) }
            "channel#getTags" -> result.resolveResult(call) { proxy.channel.getTags().toList() }
            "channel#editTagGroups" -> result.resolveResult(call) { proxy.channel.editTagGroups(call.jsonArgs()) }
            "channel#editSubscriptionLists" -> result.resolveResult(call) { proxy.channel.editSubscriptionLists(call.jsonArgs()) }
            "channel#editAttributes" -> result.resolveResult(call) { proxy.channel.editAttributes(call.jsonArgs()) }
            "channel#getSubscriptionLists" -> result.resolvePending(call) { proxy.channel.getSubscriptionLists() }
            "channel#enableChannelCreation" -> result.resolveResult(call) { proxy.channel.enableChannelCreation() }

            // Contact
            "contact#reset" -> result.resolveResult(call) { proxy.contact.reset() }
            "contact#notifyRemoteLogin" -> result.resolveResult(call) { proxy.contact.notifyRemoteLogin() }
            "contact#identify" -> result.resolveResult(call) { proxy.contact.identify(call.stringArg()) }
            "contact#getNamedUserId" -> result.resolveResult(call) { proxy.contact.getNamedUserId() }
            "contact#editTagGroups" -> result.resolveResult(call) { proxy.contact.editTagGroups(call.jsonArgs()) }
            "contact#editSubscriptionLists" -> result.resolveResult(call) { proxy.contact.editSubscriptionLists(call.jsonArgs()) }
            "contact#editAttributes" -> result.resolveResult(call) { proxy.contact.editAttributes(call.jsonArgs()) }
            "contact#getSubscriptionLists" -> result.resolvePending(call) { proxy.contact.getSubscriptionLists() }

            // Push
            "push#setUserNotificationsEnabled" -> result.resolveResult(call) { proxy.push.setUserNotificationsEnabled(call.booleanArg()) }
            "push#enableUserNotifications" -> {
                val args = call.jsonArgs()

                val enableArgs = args?.let {
                    try {
                        EnableUserNotificationsArgs.fromJson(it)
                    } catch (e: Exception) {
                        null
                    }
                }

                coroutineScope.launch {
                    try {
                        val enableResult = proxy.push.enableUserPushNotifications(enableArgs)
                        result.success(enableResult)
                    } catch (e: Exception) {
                        result.error("ERROR", "Failed to enable user notifications", e.localizedMessage)
                    }
                }
            }
            "push#isUserNotificationsEnabled" -> result.resolveResult(call) { proxy.push.isUserNotificationsEnabled() }
            "push#getNotificationStatus" -> result.resolveResult(call) {
                coroutineScope.launch {
                    proxy.push.getNotificationStatus()
                }
            }
            "push#getActiveNotifications" -> result.resolveResult(call) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    proxy.push.getActiveNotifications()
                } else {
                    emptyList()
                }
            }
            "push#clearNotification" -> result.resolveResult(call) { proxy.push.clearNotification(call.stringArg()) }
            "push#clearNotifications" -> result.resolveResult(call) { proxy.push.clearNotifications() }
            "push#getRegistrationToken" -> result.resolveResult(call) { proxy.push.getRegistrationToken() }
            "push#android#isNotificationChannelEnabled" -> result.resolveResult(call) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    proxy.push.isNotificationChannelEnabled(call.stringArg())
                } else {
                    false
                }
            }
            "push#android#setNotificationConfig" -> result.resolveResult(call) { proxy.push.setNotificationConfig(call.jsonArgs()) }

            // In-App
            "inApp#setPaused" -> result.resolveResult(call) { proxy.inApp.setPaused(call.booleanArg()) }
            "inApp#isPaused" -> result.resolveResult(call) { proxy.inApp.isPaused() }
            "inApp#setDisplayInterval" -> result.resolveResult(call) { proxy.inApp.setDisplayInterval(call.longArg()) }
            "inApp#getDisplayInterval" -> result.resolveResult(call) { proxy.inApp.getDisplayInterval() }
            "inApp#resendLastEmbeddedEvent" -> result.resolveResult(call) { proxy.inApp.resendLastEmbeddedEvent() }

            // Analytics
            "analytics#trackScreen" -> result.resolveResult(call) { proxy.analytics.trackScreen(call.optStringArg()) }
            "analytics#addEvent" -> result.resolveResult(call) { proxy.analytics.addEvent(call.jsonArgs()) }
            "analytics#associateIdentifier" -> {
                val args = call.stringList()
                proxy.analytics.associateIdentifier(
                    args[0],
                    args.getOrNull(1)
                )
            }

            // Message Center
            "messageCenter#getMessages" -> result.resolveResult(call) {
                JsonValue.wrapOpt(proxy.messageCenter.getMessages())
            }
            "messageCenter#showMessageCenter" -> result.resolveResult(call) { proxy.messageCenter.showMessageCenter(call.optStringArg()) }
            "messageCenter#showMessageView" -> result.resolveResult(call) { proxy.messageCenter.showMessageView(call.stringArg()) }
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
            // Live Activities

            "featureFlagManager#trackInteraction" -> {
                result.resolveDeferred(call) { callback ->
                    scope.launch {
                        try {
                            val args = call.jsonArgs()

                            val wrapped = JsonValue.wrap(args)
                            val featureFlagProxy = FeatureFlagProxy(wrapped)
                            proxy.featureFlagManager.trackInteraction(flag = featureFlagProxy)
                            callback(null, null)
                        } catch (e: Exception) {
                            callback(null, e)
                        }
                    }
                }
            }

            "liveUpdate#start" -> result.resolveResult(call) {
                try {
                    val args = call.jsonArgs()
                    Log.d("AirshipPlugin", "Received args for liveUpdate#start: $args")

                    val startRequest = LiveUpdateRequest.Start.fromJson(args)

                    Log.d("AirshipPlugin", "Created LiveUpdateRequest.Start: $startRequest")

                    proxy.liveUpdateManager.start(startRequest)
                    Log.d("AirshipPlugin", "LiveUpdate start method called successfully")

                    null // Return null as the start function doesn't return anything
                } catch (e: Exception) {
                    throw e
                }
            }

            "liveUpdate#update" -> result.resolveResult(call) {
                try {
                    val args = call.jsonArgs()
                    Log.d("AirshipPlugin", "Received args for liveUpdate#update: $args")

                    val updateRequest = LiveUpdateRequest.Update.fromJson(args)

                    proxy.liveUpdateManager.update(updateRequest)
                    Log.d("AirshipPlugin", "LiveUpdate update method called successfully")
                    null
                } catch (e: Exception) {
                    Log.e("AirshipPlugin", "Error processing liveUpdate#update request", e)
                    throw e
                }
            }

            "liveUpdate#list" -> result.resolveDeferred(call) { callback ->
                try {
                    val args = call.jsonArgs()
                    Log.d("AirshipPlugin", "Received args for liveUpdate#list: $args")

                    val listRequest = LiveUpdateRequest.List.fromJson(args)

                    coroutineScope.launch {
                        try {
                            val liveUpdates = proxy.liveUpdateManager.list(listRequest)
                            Log.d("AirshipPlugin", "LiveUpdate list method completed successfully")
                            callback(liveUpdates.toJsonList(), null)
                        } catch (e: Exception) {
                            Log.e("AirshipPlugin", "Error listing LiveUpdates", e)
                            callback(null, e)
                        }
                    }
                } catch (e: Exception) {
                    Log.e("AirshipPlugin", "Error processing liveUpdate#list request", e)
                    callback(null, e)
                }
            }

            "liveUpdate#listAll" -> result.resolveDeferred(call) { callback ->
                coroutineScope.launch {
                    try {
                        val liveUpdates = proxy.liveUpdateManager.listAll()
                        Log.d("AirshipPlugin", "LiveUpdate listAll method completed successfully")
                        callback(JsonValue.wrap(liveUpdates), null)
                    } catch (e: Exception) {
                        Log.e("AirshipPlugin", "Error listing all LiveUpdates", e)
                        callback(null, e)
                    }
                }
            }

            "liveUpdate#end" -> result.resolveResult(call) {
                try {
                    val args = call.jsonArgs()
                    Log.d("AirshipPlugin", "Received args for liveUpdate#end: $args")

                    val endRequest = LiveUpdateRequest.End.fromJson(args)

                    proxy.liveUpdateManager.end(endRequest)
                    Log.d("AirshipPlugin", "LiveUpdate end method called successfully")
                    null
                } catch (e: Exception) {
                    Log.e("AirshipPlugin", "Error processing liveUpdate#end request", e)
                    throw e
                }
            }

            "liveUpdate#clearAll" -> result.resolveResult(call) {
                try {
                    proxy.liveUpdateManager.clearAll()
                    Log.d("AirshipPlugin", "LiveUpdate clearAll method called successfully")
                    null
                } catch (e: Exception) {
                    Log.e("AirshipPlugin", "Error processing liveUpdate#clearAll request", e)
                    throw e
                }
            }

            // Feature Flag
            "featureFlagManager#flag" -> result.resolveDeferred(call) { callback ->
                scope.launch {
                    try {
                        val flag = proxy.featureFlagManager.flag(call.stringArg())
                        callback(flag, null)
                    } catch (e: Exception) {
                        callback(null, e)
                    }
                }
            }

            "featureFlagManager#trackInteraction" -> {
                result.resolveDeferred(call) { callback ->
                    scope.launch {
                        try {
                            val args = call.stringArg().toMap()

                            val wrapped = JsonValue.wrap(args)
                            val featureFlagProxy = FeatureFlagProxy(wrapped)
                            proxy.featureFlagManager.trackInteraction(flag = featureFlagProxy)
                            callback(null, null)
                        } catch (e: Exception) {
                            callback(null, e)
                        }
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

    class AirshipEventStreamHandler : EventChannel.StreamHandler {
        val eventFlow: StateFlow<EventChannel.EventSink?> get() = _eventSink

        private var _eventSink: MutableStateFlow<EventChannel.EventSink?> = MutableStateFlow(null)

        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            this._eventSink.value = events
        }

        override fun onCancel(arguments: Any?) {
            this._eventSink.value = null
        }

        fun notify(event: Any): Boolean {
            return _eventSink.value?.let {
                it.success(event)

                true
            } ?: false
        }
    }
    class AirshipEventStream(
        private val eventTypes: List<EventType>,
        private val name: String,
        private val binaryMessenger: BinaryMessenger
    ) {
        private val handlers = mutableListOf<AirshipEventStreamHandler>()
        private val lock = ReentrantLock()
        private val coroutineScope = CoroutineScope(Dispatchers.Main + SupervisorJob())

        fun register() {
            val eventChannel = EventChannel(binaryMessenger, name)
            val handler = AirshipEventStreamHandler()
            eventChannel.setStreamHandler(handler)

            lock.withLock {
                handlers.add(handler)
            }

            coroutineScope.launch {
                handler.eventFlow.filterNotNull().collect {
                    processPendingEvents()
                }
            }
        }

        fun processPendingEvents() {
            EventEmitter.shared().processPending(eventTypes) { event ->
                val unwrappedEvent = event.body.unwrap()
                if (unwrappedEvent != null) {
                    notify(unwrappedEvent)
                } else {
                    /// If it can't be unwrapped we've processed all we can
                    true
                }
            }
        }

        private fun notify(event: Any): Boolean {
            return lock.withLock {
                handlers.any { it.notify(event) }
            }
        }
    }
}