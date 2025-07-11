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
import io.flutter.plugin.platform.PlatformViewRegistry
import kotlinx.coroutines.CoroutineScope
import java.util.concurrent.locks.ReentrantLock
import kotlin.concurrent.withLock
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.filterNotNull
import kotlinx.coroutines.launch
import kotlin.time.Duration.Companion.milliseconds


class AirshipPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private val scope: CoroutineScope = CoroutineScope(Dispatchers.Main + SupervisorJob())
    private var mainActivity: Activity? = null
    private lateinit var streams: Map<EventType, AirshipEventStream>

    companion object {
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

        when (call.method) {
            // Flutter
            "startBackgroundIsolate" -> startBackgroundIsolate(call, result)

            // Airship
            "takeOff" -> result.resolve(scope, call) { proxy.takeOff(call.jsonArgs()) }
            
            "isFlying" -> result.resolve(scope, call) { proxy.isFlying() }

            // Channel
            "channel#getChannelId" -> result.resolve(scope, call) { proxy.channel.getChannelId() }
            "channel#waitForChannelId" -> result.resolve(scope, call) { proxy.channel.waitForChannelId() }
            "channel#addTags" -> result.resolve(scope, call) {
                call.stringList().forEach {
                    proxy.channel.addTag(it)
                }
            }

            "channel#removeTags" -> result.resolve(scope, call) {
                call.stringList().forEach {
                    proxy.channel.removeTag(it)
                }
            }

            "channel#editTags" -> result.resolve(scope, call) { proxy.channel.editTags(call.jsonArgs()) }
            "channel#getTags" -> result.resolve(scope, call) { proxy.channel.getTags().toList() }
            "channel#editTagGroups" -> result.resolve(scope, call) { proxy.channel.editTagGroups(call.jsonArgs()) }
            "channel#editSubscriptionLists" -> result.resolve(scope, call) { proxy.channel.editSubscriptionLists(call.jsonArgs()) }
            "channel#editAttributes" -> result.resolve(scope, call) { proxy.channel.editAttributes(call.jsonArgs()) }
            "channel#getSubscriptionLists" -> result.resolve(scope, call) { proxy.channel.getSubscriptionLists() }
            "channel#enableChannelCreation" -> result.resolve(scope, call) { proxy.channel.enableChannelCreation() }

            // Contact
            "contact#reset" -> result.resolve(scope, call) { proxy.contact.reset() }
            "contact#notifyRemoteLogin" -> result.resolve(scope, call) { proxy.contact.notifyRemoteLogin() }
            "contact#identify" -> result.resolve(scope, call) { proxy.contact.identify(call.stringArg()) }
            "contact#getNamedUserId" -> result.resolve(scope, call) { proxy.contact.getNamedUserId() }
            "contact#editTagGroups" -> result.resolve(scope, call) { proxy.contact.editTagGroups(call.jsonArgs()) }
            "contact#editSubscriptionLists" -> result.resolve(scope, call) { proxy.contact.editSubscriptionLists(call.jsonArgs()) }
            "contact#editAttributes" -> result.resolve(scope, call) { proxy.contact.editAttributes(call.jsonArgs()) }
            "contact#getSubscriptionLists" -> result.resolve(scope, call) { proxy.contact.getSubscriptionLists() }

            // Push
            "push#setUserNotificationsEnabled" -> result.resolve(scope, call) { proxy.push.setUserNotificationsEnabled(call.booleanArg()) }
            "push#enableUserNotifications" -> result.resolve(scope, call) {
                val enableArgs = call.jsonArgs().let {
                    EnableUserNotificationsArgs.fromJson(it)
                }
                proxy.push.enableUserPushNotifications(enableArgs)
            }
            "push#isUserNotificationsEnabled" -> result.resolve(scope, call) { proxy.push.isUserNotificationsEnabled() }
            "push#getNotificationStatus" -> result.resolve(scope, call) { proxy.push.getNotificationStatus() }
            "push#getActiveNotifications" -> result.resolve(scope, call) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    proxy.push.getActiveNotifications()
                } else {
                    emptyList()
                }
            }
            "push#clearNotification" -> result.resolve(scope, call) { proxy.push.clearNotification(call.stringArg()) }
            "push#clearNotifications" -> result.resolve(scope, call) { proxy.push.clearNotifications() }
            "push#getRegistrationToken" -> result.resolve(scope, call) { proxy.push.getRegistrationToken() }
            "push#android#isNotificationChannelEnabled" -> result.resolve(scope, call) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    proxy.push.isNotificationChannelEnabled(call.stringArg())
                } else {
                    false
                }
            }
            "push#android#setNotificationConfig" -> result.resolve(scope, call) { proxy.push.setNotificationConfig(call.jsonArgs()) }

            // In-App
            "inApp#setPaused" -> result.resolve(scope, call) { proxy.inApp.setPaused(call.booleanArg()) }
            "inApp#isPaused" -> result.resolve(scope, call) { proxy.inApp.isPaused() }
            "inApp#setDisplayInterval" -> result.resolve(scope, call) { proxy.inApp.setDisplayInterval(call.longArg()) }
            "inApp#getDisplayInterval" -> result.resolve(scope, call) { proxy.inApp.getDisplayInterval() }
            "inApp#resendLastEmbeddedEvent" -> result.resolve(scope, call) { proxy.inApp.resendLastEmbeddedEvent() }

            // Analytics
            "analytics#trackScreen" -> result.resolve(scope, call) { proxy.analytics.trackScreen(call.optStringArg()) }
            "analytics#addEvent" -> result.resolve(scope, call) { proxy.analytics.addEvent(call.jsonArgs()) }
            "analytics#associateIdentifier" -> {
                val args = call.stringList()
                proxy.analytics.associateIdentifier(
                    args[0],
                    args.getOrNull(1)
                )
            }

            // Message Center
            "messageCenter#getMessages" -> result.resolve(scope, call) { proxy.messageCenter.getMessages() }
            "messageCenter#showMessageCenter" -> result.resolve(scope, call) { proxy.messageCenter.showMessageCenter(call.optStringArg()) }
            "messageCenter#showMessageView" -> result.resolve(scope, call) { proxy.messageCenter.showMessageView(call.stringArg()) }
            "messageCenter#display" -> result.resolve(scope, call) { proxy.messageCenter.display(call.optStringArg()) }
            "messageCenter#markMessageRead" -> result.resolve(scope, call) { proxy.messageCenter.markMessageRead(call.stringArg()) }
            "messageCenter#deleteMessage" -> result.resolve(scope, call) { proxy.messageCenter.deleteMessage(call.stringArg()) }
            "messageCenter#getUnreadMessageCount" -> result.resolve(scope, call) { proxy.messageCenter.getUnreadMessagesCount()  }
            "messageCenter#setAutoLaunch" -> result.resolve(scope, call) { proxy.messageCenter.setAutoLaunchDefaultMessageCenter(call.booleanArg()) }
            "messageCenter#refreshMessages" -> result.resolve(scope, call) {  proxy.messageCenter.refreshInbox() }

            // Preference Center
            "preferenceCenter#display" -> result.resolve(scope, call) { proxy.preferenceCenter.displayPreferenceCenter(call.stringArg()) }
            "preferenceCenter#getConfig" -> result.resolve(scope, call) { proxy.preferenceCenter.getPreferenceCenterConfig(call.stringArg()) }
            "preferenceCenter#setAutoLaunch" -> result.resolve(scope, call) {
                val args = call.jsonArgs().requireList()
                proxy.preferenceCenter.setAutoLaunchPreferenceCenter(
                    args.get(0).requireString(),
                    args.get(1).getBoolean(false)
                )
            }

            // Privacy Manager
            "privacyManager#setEnabledFeatures" -> result.resolve(scope, call) { proxy.privacyManager.setEnabledFeatures(call.stringList()) }
            "privacyManager#getEnabledFeatures" -> result.resolve(scope, call) { proxy.privacyManager.getFeatureNames() }
            "privacyManager#enableFeatures" -> result.resolve(scope, call) { proxy.privacyManager.enableFeatures(call.stringList()) }
            "privacyManager#disableFeatures" -> result.resolve(scope, call) { proxy.privacyManager.disableFeatures(call.stringList()) }
            "privacyManager#isFeaturesEnabled" -> result.resolve(scope, call) { proxy.privacyManager.isFeatureEnabled(call.stringList()) }

            // Locale
            "locale#setLocaleOverride" -> result.resolve(scope, call) { proxy.locale.setCurrentLocale(call.stringArg()) }
            "locale#getCurrentLocale" -> result.resolve(scope, call) { proxy.locale.getCurrentLocale() }
            "locale#clearLocaleOverride" -> result.resolve(scope, call) { proxy.locale.clearLocale() }

            // Actions
            "actions#run" -> result.resolve(scope, call) {
                val args = call.jsonArgs().requireList().list

                val actionResult = proxy.actions.runAction(args[0].requireString(), args.getOrNull(1))

                if (actionResult.status == ActionResult.STATUS_COMPLETED) {
                    actionResult.value
                } else {
                    throw Exception("Action failed with status: ${actionResult.status}")
                }
            }

            // Live Activities
            "liveUpdate#start" -> result.resolve(scope, call) {
                val args = call.jsonArgs()
                Log.d("AirshipPlugin", "Received args for liveUpdate#start: $args")

                val startRequest = LiveUpdateRequest.Start.fromJson(args)

                Log.d("AirshipPlugin", "Created LiveUpdateRequest.Start: $startRequest")

                proxy.liveUpdateManager.start(startRequest)
                Log.d("AirshipPlugin", "LiveUpdate start method called successfully")

                null // Return null as the start function doesn't return anything
            }

            "liveUpdate#update" -> result.resolve(scope, call) {
                val args = call.jsonArgs()
                Log.d("AirshipPlugin", "Received args for liveUpdate#update: $args")

                val updateRequest = LiveUpdateRequest.Update.fromJson(args)

                proxy.liveUpdateManager.update(updateRequest)
                Log.d("AirshipPlugin", "LiveUpdate update method called successfully")
                null
            }

            "liveUpdate#list" -> result.resolve(scope, call) {
                val args = call.jsonArgs()
                Log.d("AirshipPlugin", "Received args for liveUpdate#list: $args")

                val listRequest = LiveUpdateRequest.List.fromJson(args)
                proxy.liveUpdateManager.list(listRequest)
                Log.d("AirshipPlugin", "LiveUpdate list method completed successfully")
            }

            "liveUpdate#listAll" -> result.resolve(scope, call) {
                proxy.liveUpdateManager.listAll()
                Log.d("AirshipPlugin", "LiveUpdate listAll method completed successfully")
            }

            "liveUpdate#end" -> result.resolve(scope, call) {
                val args = call.jsonArgs()
                Log.d("AirshipPlugin", "Received args for liveUpdate#end: $args")

                val endRequest = LiveUpdateRequest.End.fromJson(args)

                proxy.liveUpdateManager.end(endRequest)
                Log.d("AirshipPlugin", "LiveUpdate end method called successfully")
                null
            }

            "liveUpdate#clearAll" -> result.resolve(scope, call) {
                proxy.liveUpdateManager.clearAll()
                Log.d("AirshipPlugin", "LiveUpdate clearAll method called successfully")
                null
            }

            // Feature Flag
            "featureFlagManager#flag" -> result.resolve(scope, call) {
                val args = call.jsonArgs().requireMap()
                val flagName = args.get("flagName")?.requireString()
                val useResultCache = args.get("useResultCache")?.getBoolean(false) ?: false
                if (flagName == null) {
                    throw Exception("Missing flagName")
                }
                proxy.featureFlagManager.flag(flagName, useResultCache)
            }

            "featureFlagManager#trackInteraction" -> result.resolve(scope, call) {
                val parsedFlag = FeatureFlagProxy(JsonValue.wrap(call.stringArg().toMap()))
                proxy.featureFlagManager.trackInteraction(parsedFlag)
            }

            "featureFlagManager#resultCacheRemoveFlag" -> result.resolve(scope, call) {
                proxy.featureFlagManager.resultCache.removeCachedFlag(call.stringArg())
            }

            "featureFlagManager#resultCacheSetFlag"-> result.resolve(scope, call) {
                val args = call.jsonArgs().requireMap()
                val flag = FeatureFlagProxy(JsonValue.wrap(args.get("flag")?.requireString()?.toMap()))
                val ttl = args.get("ttl")?.getLong(0)
                val miliseconds = ttl?.milliseconds ?: throw Exception("Missing ttl")
                proxy.featureFlagManager.resultCache.cache(flag, miliseconds)

            }

            "featureFlagManager#resultCacheRemoveFlag" -> result.resolve(scope, call) {
                proxy.featureFlagManager.resultCache.removeCachedFlag(call.stringArg())
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