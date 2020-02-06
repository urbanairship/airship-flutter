import 'dart:async';
import 'dart:convert';
import 'package:airship_flutter/src/attribute_editor.dart';
import 'package:flutter/services.dart';
import 'custom_event.dart';
import 'tag_group_editor.dart';

class InboxMessage {
  final String title;
  final String messageId;
  final String sentDate;
  final String expirationDate;

  final String listIcon;
  final bool isRead;
  final Map<String, dynamic> extras;

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

class Notification {
  final String notificationId;
  final String alert;
  final String title;
  final String subtitle;
  final Map<String, dynamic> extras;

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

class NotificationResponseEvent {
  final String actionId;
  final bool isForeground;
  final Notification notification;
  final Map<String, dynamic> payload;

  const NotificationResponseEvent._internal(
    this.actionId,
    this.isForeground,
    this.notification,
    this.payload,
  );

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

class PushReceivedEvent {
  final Map<String, dynamic> payload;
  final Notification notification;

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

class ChannelEvent {
  final String channelId;
  final String registrationToken;

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

class Airship {
  static const MethodChannel _channel =
      const MethodChannel('com.airship.flutter/airship');
  static Map<String, EventChannel> _eventChannels = new Map();
  static Map<String, Stream<dynamic>> _eventStreams = new Map();

  static Stream<dynamic> _getEventStream(String eventType) {
    if (_eventChannels[eventType] == null) {
      String name = "com.airship.flutter/event/$eventType";
      _eventChannels[eventType] = EventChannel(name);
    }

    if (_eventStreams[eventType] == null) {
      _eventStreams[eventType] =
          _eventChannels[eventType].receiveBroadcastStream();
    }

    return _eventStreams[eventType];
  }

  static Future<String> get channelId async {
    return await _channel.invokeMethod('getChannelId');
  }

  static Future<bool> setUserNotificationsEnabled(bool enabled) async {
    if (enabled == null) {
      throw ArgumentError.notNull('enabled');
    }

    return await _channel.invokeMethod('setUserNotificationsEnabled', enabled);
  }

  static Future<void> clearNotification(String notification) async {
    if (notification == null) {
      throw ArgumentError.notNull('notification');
    }

    return await _channel.invokeMethod('clearNotification', notification);
  }

  static Future<void> clearNotifications() async {
    return await _channel.invokeMethod('clearNotifications');
  }

  static Future<List<String>> get tags async {
    List tags = await _channel.invokeMethod("getTags");
    return tags.cast<String>();
  }

  static Future<List<InboxMessage>> get inboxMessages async {
    List inboxMessages = await _channel.invokeMethod("getInboxMessages");
    return inboxMessages.map((dynamic payload) {
      return InboxMessage._fromJson(jsonDecode(payload));
    }).toList();
  }

  static Future<void> addEvent(CustomEvent event) async {
    if (event == null) {
      throw ArgumentError.notNull('event');
    }
    return await _channel.invokeMethod('addEvent', event.toMap());
  }

  static Future<void> addTags(List<String> tags) async {
    if (tags == null) {
      throw ArgumentError.notNull('tags');
    }
    return await _channel.invokeMethod('addTags', tags);
  }

  static Future<void> removeTags(List<String> tags) async {
    if (tags == null) {
      throw ArgumentError.notNull('tags');
    }
    return await _channel.invokeMethod('removeTags', tags);
  }

  static AttributeEditor editAttributes() {
    return AttributeEditor('editAttributes', _channel);
  }

  static TagGroupEditor editChannelTagGroups() {
    return TagGroupEditor('editChannelTagGroups', _channel);
  }

  static TagGroupEditor editNamedUserTagGroups() {
    return TagGroupEditor('editNamedUserTagGroups', _channel);
  }

  static Future<void> setNamedUser(String namedUser) async {
    return await _channel.invokeMethod('setNamedUser', namedUser);
  }

  static Future<void> markInboxMessageRead(InboxMessage message) async {
    if (message == null) {
      throw ArgumentError.notNull('message');
    }
    return await _channel.invokeMethod(
        'markInboxMessageRead', message.messageId);
  }

  static Future<void> deleteInboxMessage(InboxMessage message) async {
    if (message == null) {
      throw ArgumentError.notNull('message');
    }
    return await _channel.invokeMethod('deleteInboxMessage', message.messageId);
  }

  static Future<String> get namedUser async {
    return await _channel.invokeMethod('getNamedUser');
  }

  static Future<bool> get userNotificationsEnabled async {
    return await _channel.invokeMethod('getUserNotificationsEnabled');
  }

  static Future<List<Notification>> get activeNotifications async {
    List notifications = await _channel.invokeMethod('getActiveNotifications');
    return notifications.map((dynamic payload) {
      return Notification._fromJson(Map<String, dynamic>.from(payload));
    }).toList();
  }

  static Future<void> enableChannelCreation() async {
    return await _channel.invokeMethod('enableChannelCreation');
  }

  static Stream<void> get onInboxUpdated {
    return _getEventStream("INBOX_UPDATED");
  }

  static Stream<void> get onShowInbox {
    return _getEventStream("SHOW_INBOX");
  }

  static Stream<String> get onShowInboxMessage {
    return _getEventStream("SHOW_INBOX_MESSAGE")
        .map((dynamic value) => jsonDecode(value) as String);
  }

  static Stream<PushReceivedEvent> get onPushReceived {
    return _getEventStream("PUSH_RECEIVED")
        .map((dynamic value) => PushReceivedEvent._fromJson(jsonDecode(value)));
  }

  static Stream<NotificationResponseEvent> get onNotificationResponse {
    return _getEventStream("NOTIFICATION_RESPONSE").map((dynamic value) =>
        NotificationResponseEvent._fromJson(jsonDecode(value)));
  }

  static Stream<ChannelEvent> get onChannelRegistration {
    return _getEventStream("CHANNEL_REGISTRATION")
        .map((dynamic value) => ChannelEvent._fromJson(jsonDecode(value)));
  }

  static Stream<String> get onDeepLink {
    return _getEventStream("DEEP_LINK")
        .map((dynamic value) => jsonDecode(value) as String);
  }

  static Future<void> setInAppAutomationPaused(bool paused) async {
    if (paused == null) {
      throw ArgumentError.notNull('paused');
    }

    return await _channel.invokeMethod('setInAppAutomationPaused', paused);
  }

  static Future<void> get getInAppAutomationPaused async {
    return await _channel.invokeMethod('getInAppAutomationPaused');
  }

  static Future<void> trackScreen(String screen) async {
    if (screen == null) {
      throw ArgumentError.notNull('screen');
    }

    return await _channel.invokeMethod('trackScreen', screen);
  }

  static Future<bool> get getDataCollectionEnabled async {
    return await _channel.invokeMethod('getDataCollectionEnabled');
  }

  static Future<bool> get getPushTokenRegistrationEnabled async {
    return await _channel.invokeMethod('getPushTokenRegistrationEnabled');
  }

  static Future<bool> setDataCollectionEnabled(bool enabled) async {
    if (enabled == null) {
      throw ArgumentError.notNull('enabled');
    }

    return await _channel.invokeMethod('setDataCollectionEnabled', enabled);
  }

  static Future<bool> setPushTokenRegistrationEnabled(bool enabled) async {
    if (enabled == null) {
      throw ArgumentError.notNull('enabled');
    }

    return await _channel.invokeMethod('setPushTokenRegistrationEnabled', enabled);
  }
}
