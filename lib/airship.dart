import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

class InboxMessage {

  final String title;
  final String messageId;
  final String sentDate;
  final String expirationDate;

  final String listIcon;
  final bool isRead;
  final Map<String, dynamic> extras;

  const InboxMessage._internal(this.title, this.messageId, this.sentDate, this.expirationDate, this.listIcon, this.isRead, this.extras);

  static InboxMessage _fromJson(Map<String, dynamic> json) {
    var title = json["title"];
    var messageId = json["message_id"];
    var sentDate = json["sent_date"];
    var expirationDate = json["expiration_date"];
    var listIcon = json["list_icon"];
    var isRead = json["is_read"];
    var extras = json["extras"];
    return InboxMessage._internal(title, messageId, sentDate, expirationDate, listIcon, isRead, extras);
  }
}

class Airship {

  static const MethodChannel _channel = const MethodChannel('airship');
  static const EventChannel _eventChannel = const EventChannel('airship_events');

  static Stream<Map<String, dynamic>> _eventStream;

  static Stream<Map<String, dynamic>> get _onEvent {
    if (_eventStream == null) {
      _eventStream = _eventChannel.receiveBroadcastStream()
          .map((dynamic event) => jsonDecode(event));
    }
    return _eventStream;
  }

  static Future<String> get channelId async {
    return await _channel.invokeMethod('getChannelId');
  }

  static Future<void> setUserNotificationsEnabled(bool enabled) async {
    if (enabled == null) {
      throw ArgumentError.notNull('enabled');
    }

    await _channel.invokeMethod('setUserNotificationsEnabled', enabled);
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

  static Future<void> setNamedUser(String namedUser) async {
    return await _channel.invokeMethod('setNamedUser', namedUser);
  }

  static Future<void> markMessageRead(InboxMessage message) async {
    if (message == null) {
      throw ArgumentError.notNull('message');
    }
    return await _channel.invokeMethod('markMessageRead', message.messageId);
  }

  static Future<void> markMessageDeleted(InboxMessage message) async {
    if (message == null) {
      throw ArgumentError.notNull('message');
    }
    return await _channel.invokeMethod('markMessageDeleted', message.messageId);
  }

  static Future<String> get namedUser async {
    return await _channel.invokeMethod('getNamedUser');
  }

  static Future<bool> get userNotificationsEnabled async {
    return await _channel.invokeMethod('getUserNotificationsEnabled');
  }

  static Stream<void> get onInboxUpdated {
    return _onEvent.where((Map<String, dynamic> event) => event['event_type'] == "INBOX_UPDATED")
        .map((Map<String, dynamic> event) =>  null);
  }

  static Stream<String> get onShowInbox {
    return _onEvent.where((Map<String, dynamic> event) => event['event_type'] == "SHOW_INBOX")
        .map((Map<String, dynamic> event) =>  event['data']);
  }

  static Stream<Map<String, dynamic>> get onPushReceived {
    return _onEvent.where((Map<String, dynamic> event) => event['event_type'] == "PUSH_RECEIVED")
        .map((Map<String, dynamic> event) =>  event['data']);
  }

  static Stream<String> get onChannelUpdated {
    return _onEvent
        .where((Map<String, dynamic> event) => event['event_type'] == "CHANNEL_UPDATED")
        .map((Map<String, dynamic> event) =>  event['data']);
  }

  static Stream<String> get onChannelCreated {
    return _onEvent
        .where((Map<String, dynamic> event) => event['event_type'] == "CHANNEL_CREATED")
        .map((Map<String, dynamic> event) =>  event['data']);
  }
}
