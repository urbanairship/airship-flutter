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
import 'airship_channel.dart';

/// The Main Airship API.
class Airship {
  static const MethodChannel _channel =
      const MethodChannel('com.airship.flutter/airship');
  static const MethodChannel _backgroundChannel =
      const MethodChannel('com.airship.flutter/airship_background');

  static const channel = AirshipChannel(_channel);

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
