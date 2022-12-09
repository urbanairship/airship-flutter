import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'custom_event.dart';
import 'tag_group_editor.dart';
import 'subscription_list_editor.dart';
import 'scoped_subscription_list_editor.dart';
import 'preference_center_config.dart';
import 'attribute_editor.dart';

/// Inbox message object.
class InboxMessage {
  /// The message title.
  final String? title;

  /// The message ID. Needed to display, mark as read, or delete the message.
  final String messageId;

  /// The message sent date in milliseconds.
  final String? sentDate;

  /// The message expiration date in milliseconds.
  final String? expirationDate;

  /// Optional - The icon url for the message.
  final String? listIcon;

  /// The unread / read status of the message.
  final bool? isRead;

  /// String to String map of any message extras.
  final Map<String, dynamic>? extras;

  const InboxMessage._internal(this.title, this.messageId, this.sentDate,
      this.expirationDate, this.listIcon, this.isRead, this.extras);

  static InboxMessage _fromJson(Map<String, dynamic> json) {
    var title = json["title"];
    var messageId = json["message_id"];
    var sentDate = json["sent_date"];
    var expirationDate = json["expiration_date"];
    var listIcon = json["list_icon"];
    var isRead = json["is_read"];
    var extras = json["extras"];
    return InboxMessage._internal(
        title, messageId, sentDate, expirationDate, listIcon, isRead, extras);
  }

  @override
  String toString() {
    return "InboxMessage(title=$title, messageId=$messageId)";
  }
}

/// Push notification object.
class Notification {
  /// The notification ID.
  final String? notificationId;

  /// The notification alert.
  final String? alert;

  /// The notification title.
  final String? title;

  /// The notification subtitle.
  final String? subtitle;

  /// The notification extras.
  final Map<String, dynamic>? extras;

  const Notification._internal(
      this.notificationId, this.alert, this.title, this.subtitle, this.extras);

  static Notification _fromJson(Map<String, dynamic> json) {
    var notificationId = json["notification_id"];
    var alert = json["alert"];
    var title = json["title"];
    var subtitle = json["subtitle"];
    var extras;
    if (json["extras"] != null) {
      extras = Map<String, dynamic>.from(json["extras"]);
    }
    return Notification._internal(
        notificationId, alert, title, subtitle, extras);
  }

  @override
  String toString() {
    return "Notification(notificationId=$notificationId, alert=$alert, title=$title, subtitle=$subtitle, extras=$extras)";
  }
}

/// Subscription list object.
class SubscriptionList {
  /// Channel subscription lists.
  final List<String>? channelSubscriptionLists;

  /// Contact subscription lists.
  final List<ContactSubscriptionList>? contactSubscriptionLists;

  const SubscriptionList._internal(
      this.channelSubscriptionLists, this.contactSubscriptionLists);

  static SubscriptionList _fromJson(Map<String, dynamic> json) {
    var channelSubscriptionLists = <String>[];
    if (json["channel"] != null) {
      channelSubscriptionLists = List<String>.from(json["channel"]);
    }
    var contactSubscriptionLists = <ContactSubscriptionList>[];
    if (json["contact"] != null) {
      var lists = Map<String, dynamic>.from(json["contact"]);
      lists.forEach((k, v) => contactSubscriptionLists
          .add(ContactSubscriptionList._fromJson(k, List<String>.from(v))));
    }

    return SubscriptionList._internal(
        channelSubscriptionLists, contactSubscriptionLists);
  }

  @override
  String toString() {
    return "SubscriptionList(channelSubscriptionLists=$channelSubscriptionLists, contactSubscriptionLists=$contactSubscriptionLists)";
  }
}

/// Contact subscription list object.
class ContactSubscriptionList {
  /// The contact subscription list identifier.
  final String identifier;

  /// The contact subscription list scope.
  final List<String> scopes;

  const ContactSubscriptionList._internal(this.identifier, this.scopes);

  static ContactSubscriptionList _fromJson(
      String identifier, List<String> scopes) {
    return ContactSubscriptionList._internal(identifier, scopes);
  }

  @override
  String toString() {
    return "ContactSubscriptionList(identifier=$identifier, scopes=$scopes)";
  }
}

/// Event fired when the user initiates a notification response.
class NotificationResponseEvent {
  /// The action button ID, if available.
  final String? actionId;

  /// Indicates whether the response was a foreground action.
  ///
  /// This value is always if the user taps the main notification,
  /// otherwise it is defined by the notification action button.
  final bool? isForeground;

  /// The push [Notification].
  final Notification notification;

  /// The notification payload.
  final Map<String, dynamic>? payload;

  const NotificationResponseEvent._internal(
      this.actionId, this.isForeground, this.notification, this.payload);

  static NotificationResponseEvent _fromJson(Map<String, dynamic> json) {
    var actionId = json["action_id"];
    var isForeground = json["is_foreground"];
    var notification = Notification._fromJson(json["notification"]);
    var payload = json["payload"];
    return NotificationResponseEvent._internal(
        actionId, isForeground, notification, payload);
  }

  @override
  String toString() {
    return "NotificationResponseEvent(actionId=$actionId, isForeground=$isForeground, notification=$notification, payload=$payload)";
  }
}

/// Event fired when a push is received.
class PushReceivedEvent {
  /// The notification payload.
  final Map<String, dynamic>? payload;

  /// The push [Notification].
  final Notification? notification;

  const PushReceivedEvent._internal(this.payload, this.notification);

  static PushReceivedEvent _fromJson(Map<String, dynamic> json) {
    var payload = json["payload"];

    var notification;
    if (json["notification"] != null) {
      notification = Notification._fromJson(json["notification"]);
    }

    return PushReceivedEvent._internal(payload, notification);
  }

  @override
  String toString() {
    return "PushReceivedEvent(payload=$payload, notification=$notification)";
  }
}

@pragma('vm:entry-point')
void _backgroundMessageIsolateCallback() {
  WidgetsFlutterBinding.ensureInitialized();

  Airship._backgroundChannel.setMethodCallHandler((call) async {
    if (call.method == "onBackgroundMessage") {
      final args = call.arguments;
      final handle = CallbackHandle.fromRawHandle(args["messageCallback"]);
      final callback = PluginUtilities.getCallbackFromHandle(handle)
          as BackgroundMessageHandler;
      try {
        final payload = Map<String, dynamic>.from(jsonDecode(args["payload"]));
        var notification;
        if (args["notification"] != null) {
          notification =
              Notification._fromJson(jsonDecode(args["notification"]));
        }
        await callback(payload, notification);
      } catch (e) {
        print("Airship: Failed to handle background message!");
        print(e);
      }
    } else {
      throw UnimplementedError("${call.method} is not implemented!");
    }
  });

  // Tell the native side to start the background isolate.
  Airship._backgroundChannel.invokeMethod<void>("backgroundIsolateStarted");
}

typedef BackgroundMessageHandler = Future<void> Function(
    Map<String, dynamic> payload, Notification? notification);

/// Event fired when a channel registration occurs.
class ChannelEvent {
  /// The channel ID.
  final String? channelId;

  /// The registration token.
  ///
  /// The registration token might be undefined
  /// if registration is currently in progress, if the app is not setup properly
  /// for remote notifications, if running on an iOS simulator, or if running on
  /// an Android device that has an outdated or missing version of Google Play Services.
  final String? registrationToken;

  const ChannelEvent._internal(this.channelId, this.registrationToken);

  static ChannelEvent _fromJson(Map<String, dynamic> json) {
    var channelId = json["channel_id"];
    var registrationToken = json["registration_token"];
    return ChannelEvent._internal(channelId, registrationToken);
  }

  @override
  String toString() {
    return "ChannelEvent(channelId=$channelId, registrationToken=$registrationToken)";
  }
}

/// The Main Airship API.
class Airship {
  static const MethodChannel _channel =
      const MethodChannel('com.airship.flutter/airship');
  static const MethodChannel _backgroundChannel =
      const MethodChannel('com.airship.flutter/airship_background');
  static Map<String, EventChannel> _eventChannels = new Map();
  static Map<String, Stream<dynamic>> _eventStreams = new Map();
  static bool _isBackgroundHandlerSet = false;

  static Stream<dynamic>? _getEventStream(String eventType) {
    if (_eventChannels[eventType] == null) {
      String name = "com.airship.flutter/event/$eventType";
      _eventChannels[eventType] = EventChannel(name);
    }

    if (_eventStreams[eventType] == null) {
      _eventStreams[eventType] =
          _eventChannels[eventType]!.receiveBroadcastStream();
    }

    return _eventStreams[eventType];
  }

  /// Initializes Airship with an [appKey] and [appSecret].
  ///
  /// Returns true if Airship has been initialized, otherwise returns false.
  static Future<bool> takeOff(String appKey, String appSecret) async {
    Map<String, String> args = {"app_key": appKey, "app_secret": appSecret};
    return await _channel.invokeMethod('takeOff', args);
  }

  /// Sets a background message handler.
  static Future<void> setBackgroundMessageHandler(
      BackgroundMessageHandler handler) async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    if (_isBackgroundHandlerSet) {
      print("Airship background message handler already set!");
      return;
    }
    _isBackgroundHandlerSet = true;

    final isolateCallback =
        PluginUtilities.getCallbackHandle(_backgroundMessageIsolateCallback)!;
    final messageCallback = PluginUtilities.getCallbackHandle(handler)!;
    await _channel.invokeMapMethod("startBackgroundIsolate", {
      "isolateCallback": isolateCallback.toRawHandle(),
      "messageCallback": messageCallback.toRawHandle()
    });
  }

  /// Gets the channel ID.
  static Future<String?> get channelId async {
    return await _channel.invokeMethod('getChannelId');
  }

  /// Enables or disables the user notifications.
  static Future<bool?> setUserNotificationsEnabled(bool enabled) async {
    return await _channel.invokeMethod('setUserNotificationsEnabled', enabled);
  }

  /// Clears a specific [notification].
  ///
  /// The [notification] parameter is the notification ID.
  /// Supported on Android and iOS 10+.
  static Future<void> clearNotification(String notification) async {
    return await _channel.invokeMethod('clearNotification', notification);
  }

  /// Clears all notifications for the application.
  ///
  /// Supported on Android and iOS 10+. For older iOS devices, you can set
  /// the badge number to 0 to clear notifications.
  static Future<void> clearNotifications() async {
    return await _channel.invokeMethod('clearNotifications');
  }

  /// Gets the channel tags.
  static Future<List<String>> get tags async {
    List tags = await (_channel.invokeMethod("getTags"));
    return tags.cast<String>();
  }

  /// Gets the current inbox messages.
  static Future<List<InboxMessage>> get inboxMessages async {
    List inboxMessages = await (_channel.invokeMethod("getInboxMessages"));
    return inboxMessages.map((dynamic payload) {
      return InboxMessage._fromJson(jsonDecode(payload));
    }).toList();
  }

  /// Adds a custom [event].
  static Future<void> addEvent(CustomEvent event) async {
    return await _channel.invokeMethod('addEvent', event.toMap());
  }

  /// Adds channel tags.
  static Future<void> addTags(List<String> tags) async {
    return await _channel.invokeMethod('addTags', tags);
  }

  /// Removes channel tags.
  static Future<void> removeTags(List<String> tags) async {
    return await _channel.invokeMethod('removeTags', tags);
  }

  /// Creates an [AttributeEditor] to modify the channel attributes.
  ///
  /// Deprecated. Use [editChannelAttributes()] instead.
  @deprecated
  static AttributeEditor editAttributes() {
    return AttributeEditor('editAttributes', _channel);
  }

  /// Creates an [AttributeEditor] to modify the channel attributes.
  static AttributeEditor editChannelAttributes() {
    return AttributeEditor('editChannelAttributes', _channel);
  }

  /// Creates an [AttributeEditor] to modify the named user attributes.
  static AttributeEditor editNamedUserAttributes() {
    return AttributeEditor('editNamedUserAttributes', _channel);
  }

  /// Creates a [SubscriptionListEditor] to modify the subscription lists associated with the current channel.
  static SubscriptionListEditor editChannelSubscriptionLists() {
    return SubscriptionListEditor('editChannelSubscriptionLists', _channel);
  }

  /// Creates a [ScopedSubscriptionListEditor] to modify the subscription lists associated with the current contact.
  static ScopedSubscriptionListEditor editContactSubscriptionLists() {
    return ScopedSubscriptionListEditor(
        'editContactSubscriptionLists', _channel);
  }

  /// Creates a [TagGroupEditor] to modify the channel tag groups.
  static TagGroupEditor editChannelTagGroups() {
    return TagGroupEditor('editChannelTagGroups', _channel);
  }

  /// Creates a [TagGroupEditor] to modify the named user tag groups.
  static TagGroupEditor editNamedUserTagGroups() {
    return TagGroupEditor('editNamedUserTagGroups', _channel);
  }

  /// Sets the named user.
  ///
  /// Set [namedUser] at null to clear the named user.
  static Future<void> setNamedUser(String? namedUser) async {
    return await _channel.invokeMethod('setNamedUser', namedUser);
  }

  /// Marks an inbox [message] as read.
  static Future<void> markInboxMessageRead(InboxMessage message) async {
    return await _channel.invokeMethod(
        'markInboxMessageRead', message.messageId);
  }

  /// Deletes an inbox [message].
  static Future<void> deleteInboxMessage(InboxMessage message) async {
    return await _channel.invokeMethod('deleteInboxMessage', message.messageId);
  }

  /// Forces the inbox to refresh.
  ///
  /// This is normally not needed as the inbox will automatically refresh on
  /// foreground or when a push arrives that's associated with a message.
  static Future<bool?> refreshInbox() async {
    return _channel.invokeMethod("refreshInbox");
  }

  /// Gets the named user.
  static Future<String?> get namedUser async {
    return await _channel.invokeMethod('getNamedUser');
  }

  /// Tells if user notifications are enabled or not.
  static Future<bool?> get userNotificationsEnabled async {
    return await _channel.invokeMethod('getUserNotificationsEnabled');
  }

  /// Gets all the active notifications for the application.
  ///
  /// Supported on Android Marshmallow (23)+ and iOS 10+.
  static Future<List<Notification>> get activeNotifications async {
    List notifications =
        await (_channel.invokeMethod('getActiveNotifications'));
    return notifications.map((dynamic payload) {
      return Notification._fromJson(Map<String, dynamic>.from(payload));
    }).toList();
  }

  /// Enables channel creation.
  static Future<void> enableChannelCreation() async {
    return await _channel.invokeMethod('enableChannelCreation');
  }

  /// Gets inbox updated event stream.
  static Stream<void>? get onInboxUpdated {
    return _getEventStream("INBOX_UPDATED");
  }

  /// Gets show inbox event stream.
  static Stream<void>? get onShowInbox {
    return _getEventStream("SHOW_INBOX");
  }

  /// Gets show inbox message event stream.
  static Stream<String?> get onShowInboxMessage {
    return _getEventStream("SHOW_INBOX_MESSAGE")!
        .map((dynamic value) => jsonDecode(value) as String?);
  }

  /// Gets show preference center event stream.
  static Stream<String?> get onShowPreferenceCenter {
    return _getEventStream("SHOW_PREFERENCE_CENTER")!
        .map((dynamic value) => jsonDecode(value) as String?);
  }

  /// Gets push received event stream.
  static Stream<PushReceivedEvent> get onPushReceived {
    return _getEventStream("PUSH_RECEIVED")!
        .map((dynamic value) => PushReceivedEvent._fromJson(jsonDecode(value)));
  }

  /// Gets notification response event stream.
  static Stream<NotificationResponseEvent> get onNotificationResponse {
    return _getEventStream("NOTIFICATION_RESPONSE")!.map((dynamic value) =>
        NotificationResponseEvent._fromJson(jsonDecode(value)));
  }

  /// Gets channel registration event stream.
  static Stream<ChannelEvent> get onChannelRegistration {
    return _getEventStream("CHANNEL_REGISTRATION")!
        .map((dynamic value) => ChannelEvent._fromJson(jsonDecode(value)));
  }

  /// Gets deep link event stream.
  static Stream<String?> get onDeepLink {
    return _getEventStream("DEEP_LINK")!
        .map((dynamic value) => jsonDecode(value) as String?);
  }

  /// Pauses or unpauses in-app automation.
  static Future<void> setInAppAutomationPaused(bool paused) async {
    return await _channel.invokeMethod('setInAppAutomationPaused', paused);
  }

  /// Checks if in-app automation is paused or not.
  static Future<void> get getInAppAutomationPaused async {
    return await _channel.invokeMethod('getInAppAutomationPaused');
  }

  /// Initiates [screen] tracking for a specific app screen. Must be called once per tracked screen.
  static Future<void> trackScreen(String screen) async {
    return await _channel.invokeMethod('trackScreen', screen);
  }

  /// Checks if auto-badging is enabled on iOS. Badging is not supported for Android.
  static Future<bool> isAutoBadgeEnabled() async {
    var isAutoBadgeEnabled = false;
    if (Platform.isIOS) {
      isAutoBadgeEnabled = await _channel.invokeMethod('isAutoBadgeEnabled');
    }
    return isAutoBadgeEnabled;
  }

  /// Enables or disables auto-badging on iOS. Badging is not supported for Android.
  static Future<void> setAutoBadgeEnabled(bool enabled) async {
    if (Platform.isIOS) {
      return await _channel.invokeMethod('setAutoBadgeEnabled', enabled);
    } else {
      return Future.value();
    }
  }

  /// Sets the [badge] number on iOS. Badging is not supported for Android.
  static Future<void> setBadge(int badge) async {
    if (Platform.isIOS) {
      return await _channel.invokeMethod('setBadge', badge);
    } else {
      return Future.value();
    }
  }

  /// Clears the badge on iOS. Badging is not supported for Android.
  static Future<void> resetBadge() async {
    if (Platform.isIOS) {
      return await _channel.invokeMethod('resetBadge');
    } else {
      return Future.value();
    }
  }

  /// Enables one or many [features].
  static Future<void> enableFeatures(List<String> features) async {
    return await _channel.invokeMethod('enableFeatures', features);
  }

  /// Disables one or many [features].
  static Future<void> disableFeatures(List<String> features) async {
    return await _channel.invokeMethod('disableFeatures', features);
  }

  /// Sets the SDK [features] that will be enabled. The rest of the features will be disabled.
  ///
  /// If all features are disabled the SDK will not make any network requests or collect data.
  /// Note that all features are enabled by default.
  static Future<void> setEnabledFeatures(List<String> features) async {
    return await _channel.invokeMethod('setEnabledFeatures', features);
  }

  /// Returns a [List] with the enabled features.
  static Future<List<String>> getEnabledFeatures() async {
    return await _channel.invokeMethod('getEnabledFeatures');
  }

  /// Checks if a given [feature] is enabled or not.
  static Future<bool> isFeatureEnabled(String feature) async {
    return await _channel.invokeMethod('isFeatureEnabled', feature);
  }

  /// Opens the Preference Center with the given [preferenceCenterID].
  static Future<void> openPreferenceCenter(String preferenceCenterID) async {
    return await _channel.invokeMethod(
        'openPreferenceCenter', preferenceCenterID);
  }

  /// Gets the subscription lists.
  ///
  /// The [subscriptionListTypes] can contain types `channel` or `contact`.
  static Future<SubscriptionList> getSubscriptionLists(
      List<String> subscriptionListTypes) async {
    var lists = await (_channel.invokeMethod(
        "getSubscriptionLists", subscriptionListTypes));
    return SubscriptionList._fromJson(Map<String, dynamic>.from(lists));
  }

  /// Returns the configuration of the Preference Center with the given [preferenceCenterID].
  static Future<PreferenceCenterConfig?> getPreferenceCenterConfig(
      String preferenceCenterID) async {
    var config = await _channel.invokeMethod(
        'getPreferenceCenterConfig', preferenceCenterID);
    return PreferenceCenterConfig.fromJson(jsonDecode(config));
  }

  /// Enables or disables auto launch Preference Center
  static Future<void> setAutoLaunchDefaultPreferenceCenter(bool enabled) async {
    return await _channel.invokeMethod('setAutoLaunchDefaultPreferenceCenter');
  }
}
