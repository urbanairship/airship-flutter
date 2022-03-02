import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:airship_flutter/src/attribute_editor.dart';
import 'package:flutter/services.dart';
import 'custom_event.dart';
import 'tag_group_editor.dart';
import 'subscription_list_editor.dart';
import 'scoped_subscription_list_editor.dart';

class InboxMessage {
  final String? title;
  final String messageId;
  final String? sentDate;
  final String? expirationDate;

  final String? listIcon;
  final bool? isRead;
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

class Notification {
  final String? notificationId;
  final String? alert;
  final String? title;
  final String? subtitle;
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

class PreferenceCenterConfig {
  final String identifier;
  final String? title;
  final String? subtitle;
  final List<PreferenceCenterSection>? sections;

  const PreferenceCenterConfig._internal(
      this.identifier, this.title, this.subtitle, this.sections);

  static PreferenceCenterConfig _fromJson(Map<String, dynamic> json) {
    var identifier = json["identifier"];
    var title = json["title"];
    var subtitle = json["subtitle"];
    var sections = <PreferenceCenterSection>[];
    var sectionList = List<dynamic>.from(json["sections"]);
    if (json["sections"] != null) {
      sectionList.forEach((section) =>
          sections.add(PreferenceCenterSection._fromJson(Map<String, dynamic>.from(section)))
      );
    }

    return PreferenceCenterConfig._internal(
        identifier, title, subtitle, sections);
  }

  @override
  String toString() {
    return "PreferenceCenterConfig(identifier=$identifier, title=$title, subtitle=$subtitle, sections=$sections)";
  }
}

class PreferenceCenterSection {
  final String identifier;
  final String? title;
  final String? subtitle;
  final List<PreferenceCenterItem>? items;

  const PreferenceCenterSection._internal(
      this.identifier, this.title, this.subtitle, this.items);

  static PreferenceCenterSection _fromJson(Map<String, dynamic> json) {
    var identifier = json["identifier"];
    var title = json["title"];
    var subtitle = json["subtitle"];
    var items = <PreferenceCenterItem>[];
    var itemList = List<dynamic>.from(json["items"]);
    if (json["items"] != null) {
      itemList.forEach((item) =>
          items.add(PreferenceCenterItem._fromJson(Map<String, dynamic>.from(item)))
      );
    }

    return PreferenceCenterSection._internal(
        identifier, title, subtitle, items);
  }

  @override
  String toString() {
    return "PreferenceCenterSection(identifier=$identifier, title=$title, subtitle=$subtitle, items=$items)";
  }
}

class PreferenceCenterItem {
  final String identifier;
  final String? subscriptionId;
  final String? title;
  final String? subtitle;
  final String? type;
  final List<PreferenceCenterComponent>? components;

  const PreferenceCenterItem._internal(
      this.identifier, this.subscriptionId,  this.title, this.subtitle, this.type, this.components);

  static PreferenceCenterItem _fromJson(Map<String, dynamic> json) {
    var identifier = json["identifier"];
    var subscriptionId = json["subscription_id"];
    var title = json["title"];
    var subtitle = json["subtitle"];
    var type = json["type"];
    var components = <PreferenceCenterComponent>[];
    var componentList = List<dynamic>.from(json["components"]);
    if (json["components"] != null) {
      componentList.forEach((component) =>
          components.add(PreferenceCenterComponent._fromJson(Map<String, dynamic>.from(component)))
      );
    }

    return PreferenceCenterItem._internal(
        identifier, subscriptionId, title, subtitle, type, components);
  }

  @override
  String toString() {
    return "PreferenceCenterItem(identifier=$identifier, subscriptionId=$subscriptionId, title=$title, subtitle=$subtitle, type=$type, components=$components)";
  }
}

class PreferenceCenterComponent {
  final String? title;
  final String? subtitle;
  final List<String>? scopes;

  const PreferenceCenterComponent._internal(
      this.title, this.subtitle, this.scopes);

  static PreferenceCenterComponent _fromJson(Map<String, dynamic> json) {
    var title = json["title"];
    var subtitle = json["subtitle"];
    var scopes = <String>[];
    if (json["scopes"] != null) {
      scopes = List<String>.from(json["scopes"]);
    }

    return PreferenceCenterComponent._internal(
        title, subtitle, scopes);
  }

  @override
  String toString() {
    return "PreferenceCenterComponent(title=$title, subtitle=$subtitle, scopes=$scopes)";
  }
}

class SubscriptionList {
  final List<String>? channelSubscriptionLists;
  final List<ContactSubscriptionList>? contactSubscriptionLists;

  const SubscriptionList._internal(this.channelSubscriptionLists, this.contactSubscriptionLists);

  static SubscriptionList _fromJson(Map<String, dynamic> json) {
    var channelSubscriptionLists = <String>[];
    if (json["channel"] != null) {
      channelSubscriptionLists = List<String>.from(json["channel"]);
    }
    var contactSubscriptionLists = <ContactSubscriptionList>[];
    if (json["contact"] != null) {
      var lists = Map<String, dynamic>.from(json["contact"]);
      lists.forEach((k, v) => contactSubscriptionLists.add(ContactSubscriptionList._fromJson(k,List<String>.from(v))));
    }

    return SubscriptionList._internal(channelSubscriptionLists, contactSubscriptionLists);
  }

  @override
  String toString() {
    return "SubscriptionList(channelSubscriptionLists=$channelSubscriptionLists, contactSubscriptionLists=$contactSubscriptionLists)";
  }
}

class ContactSubscriptionList {
  final String identifier;
  final List<String> scopes;

  const ContactSubscriptionList._internal(this.identifier, this.scopes);

  static ContactSubscriptionList _fromJson(String identifier, List<String> scopes) {
    return ContactSubscriptionList._internal(identifier, scopes);
  }

  @override
  String toString() {
    return "ContactSubscriptionList(identifier=$identifier, scopes=$scopes)";
  }
}

class NotificationResponseEvent {
  final String? actionId;
  final bool? isForeground;
  final Notification notification;
  final Map<String, dynamic>? payload;

  const NotificationResponseEvent._internal(
    this.actionId,
    this.isForeground,
    this.notification,
    this.payload
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
  final Map<String, dynamic>? payload;
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

class ChannelEvent {
  final String? channelId;
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

class Airship {
  static const MethodChannel _channel =
      const MethodChannel('com.airship.flutter/airship');
  static Map<String, EventChannel> _eventChannels = new Map();
  static Map<String, Stream<dynamic>> _eventStreams = new Map();

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

  static Future<bool> takeOff(String appKey, String appSecret) async {
    Map<String, String> args = {
      "app_key": appKey,
      "app_secret": appSecret
    };
    return await _channel.invokeMethod('takeOff', args);
  }

  static Future<String?> get channelId async {
    return await _channel.invokeMethod('getChannelId');
  }

  static Future<bool?> setUserNotificationsEnabled(bool enabled) async {
    return await _channel.invokeMethod('setUserNotificationsEnabled', enabled);
  }

  static Future<void> clearNotification(String notification) async {
    return await _channel.invokeMethod('clearNotification', notification);
  }

  static Future<void> clearNotifications() async {
    return await _channel.invokeMethod('clearNotifications');
  }

  static Future<List<String>> get tags async {
    List tags = await (_channel.invokeMethod("getTags"));
    return tags.cast<String>();
  }

  static Future<List<InboxMessage>> get inboxMessages async {
    List inboxMessages = await (_channel.invokeMethod("getInboxMessages"));
    return inboxMessages.map((dynamic payload) {
      return InboxMessage._fromJson(jsonDecode(payload));
    }).toList();
  }

  static Future<void> addEvent(CustomEvent event) async {
    return await _channel.invokeMethod('addEvent', event.toMap());
  }

  static Future<void> addTags(List<String> tags) async {
    return await _channel.invokeMethod('addTags', tags);
  }

  static Future<void> removeTags(List<String> tags) async {
    return await _channel.invokeMethod('removeTags', tags);
  }

  @deprecated static AttributeEditor editAttributes() {
    return AttributeEditor('editAttributes', _channel);
  }

  static AttributeEditor editChannelAttributes() {
    return AttributeEditor('editChannelAttributes', _channel);
  }

  static AttributeEditor editNamedUserAttributes() {
    return AttributeEditor('editNamedUserAttributes', _channel);
  }

  static SubscriptionListEditor editChannelSubscriptionLists() {
    return SubscriptionListEditor('editChannelSubscriptionLists', _channel);
  }

  static ScopedSubscriptionListEditor editContactSubscriptionLists() {
    return ScopedSubscriptionListEditor('editContactSubscriptionLists', _channel);
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
    return await _channel.invokeMethod(
        'markInboxMessageRead', message.messageId);
  }

  static Future<void> deleteInboxMessage(InboxMessage message) async {
    return await _channel.invokeMethod('deleteInboxMessage', message.messageId);
  }

  static Future<bool?> refreshInbox() async {
    return _channel.invokeMethod("refreshInbox");
  }

  static Future<String?> get namedUser async {
    return await _channel.invokeMethod('getNamedUser');
  }

  static Future<bool?> get userNotificationsEnabled async {
    return await _channel.invokeMethod('getUserNotificationsEnabled');
  }

  static Future<List<Notification>> get activeNotifications async {
    List notifications = await (_channel.invokeMethod('getActiveNotifications'));
    return notifications.map((dynamic payload) {
      return Notification._fromJson(Map<String, dynamic>.from(payload));
    }).toList();
  }

  static Future<void> enableChannelCreation() async {
    return await _channel.invokeMethod('enableChannelCreation');
  }

  static Stream<void>? get onInboxUpdated {
    return _getEventStream("INBOX_UPDATED");
  }

  static Stream<void>? get onShowInbox {
    return _getEventStream("SHOW_INBOX");
  }
  
  static Stream<String?> get onShowInboxMessage {
    return _getEventStream("SHOW_INBOX_MESSAGE")!
        .map((dynamic value) => jsonDecode(value) as String?);
  }

  static Stream<String?> get onShowPreferenceCenter {
    return _getEventStream("SHOW_PREFERENCE_CENTER")!
        .map((dynamic value) => jsonDecode(value) as String?);
  }

  static Stream<PushReceivedEvent> get onPushReceived {
    return _getEventStream("PUSH_RECEIVED")!
        .map((dynamic value) => PushReceivedEvent._fromJson(jsonDecode(value)));
  }

  static Stream<NotificationResponseEvent> get onNotificationResponse {
    return _getEventStream("NOTIFICATION_RESPONSE")!.map((dynamic value) =>
        NotificationResponseEvent._fromJson(jsonDecode(value)));
  }

  static Stream<ChannelEvent> get onChannelRegistration {
    return _getEventStream("CHANNEL_REGISTRATION")!
        .map((dynamic value) => ChannelEvent._fromJson(jsonDecode(value)));
  }

  static Stream<String?> get onDeepLink {
    return _getEventStream("DEEP_LINK")!
        .map((dynamic value) => jsonDecode(value) as String?);
  }

  static Future<void> setInAppAutomationPaused(bool paused) async {
    return await _channel.invokeMethod('setInAppAutomationPaused', paused);
  }

  static Future<void> get getInAppAutomationPaused async {
    return await _channel.invokeMethod('getInAppAutomationPaused');
  }

  static Future<void> trackScreen(String screen) async {
    return await _channel.invokeMethod('trackScreen', screen);
  }

  static Future<bool> isAutoBadgeEnabled() async {
    var isAutoBadgeEnabled = false;
    if (Platform.isIOS) {
      isAutoBadgeEnabled = await _channel.invokeMethod('isAutoBadgeEnabled');
    }
    return isAutoBadgeEnabled;
  }

  static Future<void> setAutoBadgeEnabled(bool enabled) async {
    if (Platform.isIOS) {
      return await _channel.invokeMethod('setAutoBadgeEnabled', enabled);
    } else {
      return Future.value();
    }
  }

  static Future<void> setBadge(int badge) async {
    if (Platform.isIOS) {
      return await _channel.invokeMethod('setBadge', badge);
    } else {
      return Future.value();
    }
  }

  static Future<void> resetBadge() async {
    if (Platform.isIOS) {
      return await _channel.invokeMethod('resetBadge');
    } else {
      return Future.value();
    }
  }

  static Future<void> enableFeatures(List<String> features) async {
    return await _channel.invokeMethod('enableFeatures', features);
  }

  static Future<void> disableFeatures(List<String> features) async {
    return await _channel.invokeMethod('disableFeatures', features);
  }

  static Future<void> setEnabledFeatures(List<String> features) async {
    return await _channel.invokeMethod('setEnabledFeatures', features);
  }

  static Future<List<String>> getEnabledFeatures() async {
    return await _channel.invokeMethod('getEnabledFeatures');
  }

  static Future<bool> isFeatureEnabled(String feature) async {
    return await _channel.invokeMethod('isFeatureEnabled', feature);
  }

  static Future<void> openPreferenceCenter(String preferenceCenterID) async {
    return await _channel.invokeMethod('openPreferenceCenter', preferenceCenterID);
  }

  static Future<SubscriptionList> getSubscriptionLists(List<String> subscriptionListTypes) async {
    var lists = await (_channel.invokeMethod("getSubscriptionLists", subscriptionListTypes));
    return SubscriptionList._fromJson(Map<String, dynamic>.from(lists));
  }

  static Future<PreferenceCenterConfig> getPreferenceCenterConfig(String preferenceCenterID) async {
    var config = await _channel.invokeMethod('getPreferenceCenterConfig', preferenceCenterID);
    return PreferenceCenterConfig._fromJson(Map<String, dynamic>.from(config));
  }

  static Future<void> setAutoLaunchDefaultPreferenceCenter(bool enabled) async {
    return await _channel.invokeMethod('setAutoLaunchDefaultPreferenceCenter');
  }
}

