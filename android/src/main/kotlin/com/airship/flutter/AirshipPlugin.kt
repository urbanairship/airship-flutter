package com.airship.flutter

import android.annotation.SuppressLint
import android.app.Activity
import android.app.NotificationManager
import android.content.Context
import android.graphics.Bitmap
import android.os.Build
import android.view.View
import android.webkit.WebView
import androidx.core.app.NotificationManagerCompat
import com.urbanairship.Autopilot
import com.urbanairship.PrivacyManager
import com.urbanairship.UAirship
import com.urbanairship.analytics.CustomEvent
import com.urbanairship.automation.InAppAutomation
import com.urbanairship.channel.AttributeEditor
import com.urbanairship.channel.TagGroupsEditor
import com.urbanairship.contacts.Scope
import com.urbanairship.json.JsonMap
import com.urbanairship.json.JsonValue
import com.urbanairship.messagecenter.MessageCenter
import com.urbanairship.messagecenter.webkit.MessageWebView
import com.urbanairship.messagecenter.webkit.MessageWebViewClient
import com.urbanairship.preferencecenter.PreferenceCenter
import com.urbanairship.util.DateUtils
import com.urbanairship.util.UAStringUtil
import io.flutter.embedding.engine.FlutterShellArgs
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugin.platform.PlatformViewRegistry
import kotlinx.coroutines.*

private const val TAG_OPERATION_GROUP_NAME = "group"
private const val TAG_OPERATION_TYPE = "operationType"
private const val TAG_OPERATION_TAGS = "tags"
private const val TAG_OPERATION_ADD = "add"
private const val TAG_OPERATION_REMOVE = "remove"
private const val TAG_OPERATION_SET = "set"

private const val ATTRIBUTE_MUTATION_TYPE = "action"
private const val ATTRIBUTE_MUTATION_KEY = "key"
private const val ATTRIBUTE_MUTATION_VALUE = "value"
private const val ATTRIBUTE_MUTATION_REMOVE = "remove"
private const val ATTRIBUTE_MUTATION_SET = "set"

const val AUTO_LAUNCH_PREFERENCE_CENTER_KEY = "com.airship.flutter.auto_launch_pc"

class InboxMessageViewFactory(private val binaryMessenger: BinaryMessenger) :
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        val channel = MethodChannel(binaryMessenger, "com.airship.flutter/InboxMessageView_$viewId")
        val view = FlutterInboxMessageView(checkNotNull(context), channel)
        channel.setMethodCallHandler(view)
        return view
    }
}

class FlutterInboxMessageView(private var context: Context, channel: MethodChannel) : PlatformView,
    MethodCallHandler {

    lateinit private var webviewResult: Result

    private val webView: MessageWebView by lazy {
        val view = MessageWebView(context)
        view.webViewClient = object : MessageWebViewClient() {
            override fun onPageStarted(view: WebView, url: String?, favicon: Bitmap?) {
                super.onPageStarted(view, url, favicon)
                channel.invokeMethod("onLoadStarted", null)
            }

            override fun onPageFinished(view: WebView?, url: String?) {
                super.onPageFinished(view, url)
                channel.invokeMethod("onLoadFinished", null)
            }

            override fun onClose(webView: WebView) {
                super.onClose(webView)
                channel.invokeMethod("onClose", null)
            }

            override fun onReceivedError(
                view: WebView?,
                errorCode: Int,
                description: String?,
                failingUrl: String?
            ) {
                super.onReceivedError(view, errorCode, description, failingUrl)
                if (errorCode == 410) {
                    webviewResult.error(
                        "InvalidMessage",
                        "Unable to load message",
                        "Message not available"
                    )
                } else {
                    webviewResult.error(
                        "InvalidMessage",
                        "Unable to load message",
                        "Message load failed"
                    )
                }
            }
        }
        view
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "loadMessage" -> loadMessage(call, result)
            else -> result.notImplemented()
        }
    }

    override fun getView(): View = webView

    override fun dispose() {

    }

    private fun loadMessage(call: MethodCall, result: Result) {
        webviewResult = result
        if (!(UAirship.isTakingOff() || UAirship.isFlying())) {
            result.error("AIRSHIP_GROUNDED", "Takeoff not called.", null)
            return
        }

        val message = MessageCenter.shared().inbox.getMessage(call.arguments())
        if (message != null) {
            webView.loadMessage(message)
            message.markRead()
        } else {
            result.error("InvalidMessage", "Unable to load message: ${call.arguments}", null)
        }
    }
}

class AirshipPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel

    private lateinit var context: Context

    private val sharedPreferences by lazy {
        context.getAirshipSharedPrefs()
    }

    private val scope: CoroutineScope = CoroutineScope(Dispatchers.Main) + SupervisorJob()

    private var mainActivity: Activity? = null

    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val plugin = AirshipPlugin()
            plugin.register(
                registrar.context().applicationContext,
                registrar.messenger(),
                registrar.platformViewRegistry()
            )
        }

        internal const val AIRSHIP_SHARED_PREFS = "com.urbanairship.flutter"
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        register(binding.applicationContext, binding.binaryMessenger, binding.platformViewRegistry)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun register(
        context: Context,
        binaryMessenger: BinaryMessenger,
        platformViewRegistry: PlatformViewRegistry
    ) {
        this.context = context
        this.channel = MethodChannel(binaryMessenger, "com.airship.flutter/airship")
        this.channel.setMethodCallHandler(this)
        EventManager.shared.register(binaryMessenger)
        platformViewRegistry.registerViewFactory(
            "com.airship.flutter/InboxMessageView",
            InboxMessageViewFactory(binaryMessenger)
        )
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "takeOff") {
            takeOff(call, result)
            return
        }

        if (!UAirship.isFlying() && !UAirship.isTakingOff()) {
            result.error("AIRSHIP_GROUNDED", "TakeOff not called.", null)
            return
        }

        when (call.method) {
            "startBackgroundIsolate" -> startBackgroundIsolate(call, result)
            "getChannelId" -> getChannelId(result)
            "setUserNotificationsEnabled" -> setUserNotificationsEnabled(call, result)
            "getUserNotificationsEnabled" -> getUserNotificationsEnabled(result)
            "clearNotification" -> clearNotification(call, result)
            "clearNotifications" -> clearNotifications(result)
            "getActiveNotifications" -> getActiveNotifications(result)
            "addTags" -> addTags(call, result)
            "addEvent" -> addEvent(call, result)
            "removeTags" -> removeTags(call, result)
            "getTags" -> getTags(result)
            "editChannelTagGroups" -> editChannelTagGroups(call, result)
            "editNamedUserTagGroups" -> editNamedUserTagGroups(call, result)
            "editAttributes" -> editChannelAttributes(call, result)
            "editChannelAttributes" -> editChannelAttributes(call, result)
            "editNamedUserAttributes" -> editNamedUserAttributes(call, result)
            "setNamedUser" -> setNamedUser(call, result)
            "getNamedUser" -> getNamedUser(result)
            "getInboxMessages" -> getInboxMessages(result)
            "refreshInbox" -> refreshInbox(result)
            "markInboxMessageRead" -> markInboxMessageRead(call, result)
            "deleteInboxMessage" -> deleteInboxMessage(call, result)
            "setInAppAutomationPaused" -> setInAppAutomationPaused(call, result)
            "getInAppAutomationPaused" -> getInAppAutomationPaused(result)
            "enableChannelCreation" -> enableChannelCreation(result)
            "trackScreen" -> trackScreen(call, result)
            "enableFeatures" -> enableFeatures(call, result)
            "disableFeatures" -> disableFeatures(call, result)
            "setEnabledFeatures" -> setEnabledFeatures(call, result)
            "getEnabledFeatures" -> getEnabledFeatures(result)
            "isFeatureEnabled" -> isFeatureEnabled(call, result)
            "openPreferenceCenter" -> openPreferenceCenter(call, result)
            "getSubscriptionLists" -> getSubscriptionLists(call, result)
            "editContactSubscriptionLists" -> editContactSubscriptionLists(call, result)
            "editChannelSubscriptionLists" -> editChannelSubscriptionLists(call, result)
            "getPreferenceCenterConfig" -> getPreferenceCenterConfig(call, result)
            "setAutoLaunchDefaultPreferenceCenter" -> setAutoLaunchDefaultPreferenceCenter(
                call,
                result
            )

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

    private fun getInboxMessages(result: Result) {
        val messages = MessageCenter.shared().inbox.messages
            .map { message ->
                val extras = message.extras.keySet().map { key ->
                    key to message.extras.getString(key)
                }.toMap()

                JsonMap.newBuilder()
                    .putOpt("title", message.title)
                    .putOpt("message_id", message.messageId)
                    .putOpt("sent_date", DateUtils.createIso8601TimeStamp(message.sentDateMS))
                    .putOpt("list_icon", message.listIconUrl)
                    .putOpt("is_read", message.isRead)
                    .putOpt("extras", JsonValue.wrap(extras))
                    .apply {
                        if (message.expirationDateMS != null) {
                            putOpt(
                                "expiration_date",
                                DateUtils.createIso8601TimeStamp(message.expirationDateMS!!)
                            )
                        }
                    }.build().toString()
            }

        result.success(messages)
    }

    private fun takeOff(call: MethodCall, result: Result) {
        val configByteArray = call.arguments as ByteArray

        CoroutineScope(Dispatchers.IO).launch {
            ConfigManager.shared(context).updateConfig(configByteArray)
            withContext(Dispatchers.Main) {
                Autopilot.automaticTakeOff(context)
                result.success(UAirship.isFlying() || UAirship.isTakingOff())
            }
        }
    }

    private fun refreshInbox(result: Result) {
        MessageCenter.shared().inbox.fetchMessages { success ->
            result.success(success)
        }
    }

    private fun markInboxMessageRead(call: MethodCall, result: Result) {
        val messageId = call.arguments as String?
        MessageCenter.shared().inbox.markMessagesRead(setOf(messageId))
        result.success(null)
    }

    private fun deleteInboxMessage(call: MethodCall, result: Result) {
        val messageId = call.arguments as String?
        MessageCenter.shared().inbox.deleteMessages(setOf(messageId))
        result.success(null)
    }

    private fun addTags(call: MethodCall, result: Result) {
        val tags = uncheckedCast<List<String>>(call.arguments).toSet()
        UAirship.shared().channel.editTags().addTags(tags).apply()
        result.success(null)
    }

    private fun addEvent(call: MethodCall, result: Result) {
        val eventMap = call.arguments as HashMap<*, *>

        val eventName = eventMap[CustomEvent.EVENT_NAME] as String? ?: run {
            result.success(false)
            return
        }

        val event = CustomEvent.Builder(eventName).apply {
            (eventMap[CustomEvent.EVENT_VALUE] as Int?)?.let {
                this.setEventValue(it)
            }

            this.setProperties(JsonValue.wrapOpt(eventMap[CustomEvent.PROPERTIES]).optMap())

            (eventMap[CustomEvent.TRANSACTION_ID] as String?)?.let {
                this.setTransactionId(it)
            }

            val interactionId = eventMap[CustomEvent.INTERACTION_ID] as String?
            val interactionType = eventMap[CustomEvent.INTERACTION_TYPE] as String?

            if (interactionId != null && interactionType != null) {
                this.setInteraction(interactionType, interactionId)
            }
        }.build()

        if (event.isValid) {
            event.track()
            result.success(true)
        } else {
            result.success(false)
        }
    }

    private fun removeTags(call: MethodCall, result: Result) {
        val tags = uncheckedCast<List<String>>(call.arguments).toSet()
        UAirship.shared().channel.editTags().removeTags(tags).apply()
        result.success(null)
    }

    private fun getTags(result: Result) {
        result.success(ArrayList<String>(UAirship.shared().channel.tags))
    }

    private fun editChannelTagGroups(call: MethodCall, result: Result) {
        var operations = call.arguments as ArrayList<Map<String, Any?>>
        this.applyTagGroupOperations(UAirship.shared().channel.editTagGroups(), operations)
        result.success(null)
    }

    private fun editNamedUserTagGroups(call: MethodCall, result: Result) {
        var operations = call.arguments as ArrayList<Map<String, Any?>>
        this.applyTagGroupOperations(UAirship.shared().namedUser.editTagGroups(), operations)
        result.success(null)
    }

    private fun applyTagGroupOperations(
        editor: TagGroupsEditor,
        operations: ArrayList<Map<String, Any?>>
    ) {
        for (i in 0 until operations.size) {
            val operation: Map<String, Any?> = operations[i]
            val group = operation[TAG_OPERATION_GROUP_NAME] as String
            val tags = operation[TAG_OPERATION_TAGS] as ArrayList<String?>
            val operationType = operation[TAG_OPERATION_TYPE] as String

            val tagSet = mutableSetOf<String?>()
            for (j in 0 until tags.size) {
                val tag = tags[j]
                if (tag != null) {
                    tagSet.add(tag)
                }
            }

            if (TAG_OPERATION_ADD == operationType) {
                editor.addTags(group, tagSet)
            } else if (TAG_OPERATION_REMOVE == operationType) {
                editor.removeTags(group, tagSet)
            } else if (TAG_OPERATION_SET == operationType) {
                editor.setTags(group, tagSet)
            }
        }

        editor.apply();
    }

    private fun editChannelAttributes(call: MethodCall, result: Result) {
        val mutations = call.arguments as ArrayList<Map<String, Any?>>
        this.applyAttributesOperations(UAirship.shared().channel.editAttributes(), mutations)
        result.success(null)
    }

    private fun editNamedUserAttributes(call: MethodCall, result: Result) {
        val mutations = call.arguments as ArrayList<Map<String, Any?>>
        this.applyAttributesOperations(UAirship.shared().namedUser.editAttributes(), mutations)
        result.success(null)
    }

    private fun applyAttributesOperations(
        editor: AttributeEditor,
        operations: ArrayList<Map<String, Any?>>
    ) {
        for (operation in operations) {
            val action = operation[ATTRIBUTE_MUTATION_TYPE] as? String ?: continue
            val key = operation[ATTRIBUTE_MUTATION_KEY] as? String ?: continue

            if (ATTRIBUTE_MUTATION_SET == action) {
                val value = operation[ATTRIBUTE_MUTATION_VALUE]
                if (value is String) {
                    editor.setAttribute(key, value)
                    continue
                }
                if (value is Int) {
                    editor.setAttribute(key, value)
                    continue
                }
                if (value is Long) {
                    editor.setAttribute(key, value)
                    continue
                }
                if (value is Double) {
                    editor.setAttribute(key, value)
                    continue
                }
                if (value is Float) {
                    editor.setAttribute(key, value)
                    continue
                }
            } else if (ATTRIBUTE_MUTATION_REMOVE == action) {
                editor.removeAttribute(key)
            }
        }

        editor.apply()
    }

    private fun setNamedUser(call: MethodCall, result: Result) {
        val arg = call.arguments as String?
        if (arg.isNullOrEmpty()) {
            UAirship.shared().contact.reset()
        } else {
            UAirship.shared().contact.identify(arg)
        }

        result.success(null)
    }

    private fun getNamedUser(result: Result) {
        result.success(UAirship.shared().contact.namedUserId)
    }

    private fun setUserNotificationsEnabled(call: MethodCall, result: Result) {
        UAirship.shared().pushManager.userNotificationsEnabled = call.arguments as Boolean
        result.success(true)
    }

    private fun getUserNotificationsEnabled(result: Result) {
        result.success(UAirship.shared().pushManager.userNotificationsEnabled)
    }

    private fun getActiveNotifications(result: Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val notifications = arrayListOf<Map<String, Any?>>()

            val notificationManager = UAirship.getApplicationContext()
                .getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            val statusBarNotifications = notificationManager.activeNotifications

            for (statusBarNotification in statusBarNotifications) {
                var message = statusBarNotification.pushMessage()
                val tag = statusBarNotification.tag ?: ""
                val id = statusBarNotification.id.toString()
                notifications.add(Utils.shared.notificationObject(message, tag, id))
            }
            result.success(notifications)
        } else {
            result.error(
                "UNSUPPORTED",
                "Getting active notifications is only supported on Marshmallow and newer devices.",
                null
            )
        }
    }

    private fun clearNotification(call: MethodCall, result: Result) {
        val identifier = call.arguments as String

        if (UAStringUtil.isEmpty(identifier)) {
            result.error("InvalidIdentifierFormat", "Unable to clear notification", null)
            return
        }

        val parts = identifier.split(":", ignoreCase = true, limit = 2)
        if (parts.isEmpty()) {
            result.error("InvalidIdentifierFormat", "Unable to clear notification", null)
            return
        }

        var tag = String()
        var id: Int

        try {
            id = (parts[0]).toInt()
        } catch (e: NumberFormatException) {
            result.error("InvalidIdentifierFormat", "Unable to clear notification", null)
            return
        }

        if (parts.size == 2) {
            tag = parts[1]
        }

        if (tag == "") {
            NotificationManagerCompat.from(UAirship.getApplicationContext()).cancel(null, id)
        } else {
            NotificationManagerCompat.from(UAirship.getApplicationContext()).cancel(tag, id)
        }

        result.success(true)
    }

    private fun clearNotifications(result: Result) {
        NotificationManagerCompat.from(UAirship.getApplicationContext()).cancelAll();
        result.success(true)
    }

    private fun setInAppAutomationPaused(call: MethodCall, result: Result) {
        val paused = call.arguments as Boolean

        InAppAutomation.shared().isPaused = paused
        result.success(true)
    }

    private fun getInAppAutomationPaused(result: Result) {
        result.success(InAppAutomation.shared().isPaused)
    }

    fun getChannelId(result: Result) {
        result.success(UAirship.shared().channel.id)
    }


    private fun enableChannelCreation(result: Result) {
        UAirship.shared().channel.enableChannelCreation()
        result.success(null)
    }

    private fun trackScreen(call: MethodCall, result: Result) {
        val screen = call.arguments as String
        UAirship.shared().analytics.trackScreen(screen)
        result.success(null)
    }

    private fun enableFeatures(call: MethodCall, result: Result) {
        val featureArray = call.arguments as List<String>
        val features: MutableList<Int> = mutableListOf()
        for (feature in featureArray) {
            (FeatureNames.values().firstOrNull { it.toString() == feature })?.also { featureName ->
                features.add(FeatureNames.toFeature(featureName))
            }
        }
        UAirship.shared().privacyManager.enable(*(features.toIntArray()))
        result.success(null)
    }

    private fun disableFeatures(call: MethodCall, result: Result) {
        val featureArray = call.arguments as List<String>
        val features: MutableList<Int> = mutableListOf()
        for (feature in featureArray) {
            (FeatureNames.values().firstOrNull { it.toString() == feature })?.also { featureName ->
                features.add(FeatureNames.toFeature(featureName))
            }
        }
        UAirship.shared().privacyManager.disable(*(features.toIntArray()))
        result.success(null)
    }

    private fun setEnabledFeatures(call: MethodCall, result: Result) {
        val featureArray = call.arguments as List<String>
        val features: MutableList<Int> = mutableListOf()
        for (feature in featureArray) {
            (FeatureNames.values().firstOrNull { it.toString() == feature })?.also { featureName ->
                features.add(FeatureNames.toFeature(featureName))
            }
        }
        UAirship.shared().privacyManager.setEnabledFeatures(*(features.toIntArray()))
        result.success(null)
    }

    private fun getEnabledFeatures(result: Result) {
        val features = UAirship.shared().privacyManager.enabledFeatures
        val featureArray: MutableList<String> = mutableListOf()

        if (features == PrivacyManager.FEATURE_ALL) {
            result.success(stringFromFeature(PrivacyManager.FEATURE_ALL))
            return
        }
        if (features == PrivacyManager.FEATURE_NONE) {
            result.success(stringFromFeature(PrivacyManager.FEATURE_NONE))
            return
        }

        for (featureName in FeatureNames.values()) {
            val feature = FeatureNames.toFeature(featureName)
            if ((feature and features != 0) && (feature != PrivacyManager.FEATURE_ALL)) {
                featureArray.add(featureName.toString())
            }
        }
        result.success(featureArray)
    }

    private fun isFeatureEnabled(call: MethodCall, result: Result) {
        val feature = call.arguments as String
        var isEnabled = false
        (FeatureNames.values().firstOrNull { it.toString() == feature })?.also { featureName ->
            isEnabled =
                UAirship.shared().privacyManager.isEnabled(FeatureNames.toFeature(featureName))
        }
        result.success(isEnabled)
    }

    private fun openPreferenceCenter(call: MethodCall, result: Result) {
        val preferenceCenterID = call.arguments as String

        PreferenceCenter.shared().open(preferenceCenterID)

        result.success(null)
    }

    private fun getSubscriptionLists(call: MethodCall, result: Result) {
        scope.launch(Dispatchers.Main) {
            val subscriptionLists = withContext(Dispatchers.IO) {
                val channelSubs = async {
                    UAirship.shared().channel.getSubscriptionLists(true).get()
                        ?.toList()
                        ?: emptyList()
                }
                val contactSubs = async {
                    UAirship.shared().contact.getSubscriptionLists(true).get()
                        ?.mapValues { it.value.map(Scope::toString) }
                        ?: emptyMap()
                }

                // Block until both requests complete and return a map
                mapOf(
                    "channel" to channelSubs.await(),
                    "contact" to contactSubs.await()
                )
            }

            // Callback on main dispatcher with result
            result.success(subscriptionLists)
        }
    }

    private fun editChannelSubscriptionLists(call: MethodCall, result: Result) {
        var operations = call.arguments as ArrayList<Map<String, Any?>>

        var editor = UAirship.shared().channel.editSubscriptionLists()

        operations.forEach {
            val listId = it["listId"] as String
            val operationType = it["type"] as String

            if (operationType == "subscribe") {
                editor.subscribe(listId)
            } else if (operationType == "unsubscribe") {
                editor.unsubscribe(listId)
            }
        }

        editor.apply();

        result.success(null)
    }

    private fun editContactSubscriptionLists(call: MethodCall, result: Result) {
        var operations = call.arguments as ArrayList<Map<String, Any?>>

        var editor = UAirship.shared().contact.editSubscriptionLists()

        operations.forEach {
            val listId = it["listId"] as String
            val operationType = it["type"] as String
            val scopes = it["scopes"] as ArrayList<String>

            if (operationType == "subscribe") {
                for (scope in scopes) {
                    editor.subscribe(listId, Scope.fromJson(JsonValue.parseString(scope)))
                }
            } else if (operationType == "unsubscribe") {
                for (scope in scopes) {
                    editor.unsubscribe(listId, Scope.fromJson(JsonValue.parseString(scope)))
                }
            }
        }

        editor.apply();

        result.success(null)
    }

    @SuppressLint("RestrictedApi")
    private fun getPreferenceCenterConfig(call: MethodCall, result: Result) {
        val preferenceCenterId = call.arguments as String

        PreferenceCenter.shared().getJsonConfig(preferenceCenterId).addResultCallback { config ->
            result.success(config?.toString() ?: JsonMap.EMPTY_MAP.toString())
        }
    }

    private fun setAutoLaunchDefaultPreferenceCenter(call: MethodCall, result: Result) {
        val enabled = call.arguments as Boolean

        sharedPreferences.edit().putBoolean(AUTO_LAUNCH_PREFERENCE_CENTER_KEY, enabled).apply()

        result.success(null)
    }

    private enum class FeatureNames {
        FEATURE_PUSH, FEATURE_CHAT, FEATURE_CONTACTS, FEATURE_LOCATION, FEATURE_MESSAGE_CENTER, FEATURE_ANALYTICS, FEATURE_TAGS_AND_ATTRIBUTES, FEATURE_IN_APP_AUTOMATION, FEATURE_NONE, FEATURE_ALL;

        companion object {
            fun toFeature(name: FeatureNames): Int {
                return when (name) {
                    FEATURE_PUSH -> PrivacyManager.FEATURE_PUSH
                    FEATURE_CHAT -> PrivacyManager.FEATURE_CHAT
                    FEATURE_CONTACTS -> PrivacyManager.FEATURE_CONTACTS
                    FEATURE_LOCATION -> PrivacyManager.FEATURE_LOCATION
                    FEATURE_MESSAGE_CENTER -> PrivacyManager.FEATURE_MESSAGE_CENTER
                    FEATURE_ANALYTICS -> PrivacyManager.FEATURE_ANALYTICS
                    FEATURE_TAGS_AND_ATTRIBUTES -> PrivacyManager.FEATURE_TAGS_AND_ATTRIBUTES
                    FEATURE_IN_APP_AUTOMATION -> PrivacyManager.FEATURE_IN_APP_AUTOMATION
                    FEATURE_NONE -> PrivacyManager.FEATURE_NONE
                    FEATURE_ALL -> PrivacyManager.FEATURE_ALL
                }
            }
        }
    }

    fun stringFromFeature(feature: Int): String {
        return when (feature) {
            PrivacyManager.FEATURE_PUSH -> "FEATURE_PUSH"
            PrivacyManager.FEATURE_CHAT -> "FEATURE_CHAT"
            PrivacyManager.FEATURE_CONTACTS -> "FEATURE_CONTACTS"
            PrivacyManager.FEATURE_LOCATION -> "FEATURE_LOCATION"
            PrivacyManager.FEATURE_MESSAGE_CENTER -> "FEATURE_MESSAGE_CENTER"
            PrivacyManager.FEATURE_ANALYTICS -> "FEATURE_ANALYTICS"
            PrivacyManager.FEATURE_TAGS_AND_ATTRIBUTES -> "FEATURE_TAGS_AND_ATTRIBUTES"
            PrivacyManager.FEATURE_IN_APP_AUTOMATION -> "FEATURE_IN_APP_AUTOMATION"
            PrivacyManager.FEATURE_NONE -> "FEATURE_NONE"
            PrivacyManager.FEATURE_ALL -> "FEATURE_ALL"
            else -> "unknown feature"
        }
    }

    @Suppress("UNCHECKED_CAST")
    fun <T> uncheckedCast(value: Any): T {
        return value as T
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
}
