import 'airship_module.dart';
import 'inbox_message.dart';
import 'airship_events.dart';

class AirshipMessageCenter {

  final AirshipModule _module;

  AirshipMessageCenter(AirshipModule module) : this._module = module;

  /// Gets the current inbox messages.
  Future<List<InboxMessage>> get messages async {
    List inboxMessages = await (_module.channel.invokeMethod(
        "messageCenter#getMessages"));
    return inboxMessages.map((dynamic payload) {
      return InboxMessage.fromJson(payload);
    }).toList();
  }

  /// Marks an inbox [message] as read.
  Future<void> markRead(InboxMessage message) async {
    return await _module.channel.invokeMethod(
        'messageCenter#markMessageRead', message.messageId);
  }

  /// Requests to display the Message Center.
  Future<void> display([String? messageId]) async {
    return await _module.channel.invokeMethod(
        'messageCenter#display', messageId);
  }

  /// Deletes an inbox [message].
  Future<void> deleteMessage(InboxMessage message) async {
    return await _module.channel.invokeMethod(
        'messageCenter#deleteMessage', message.messageId);
  }

  /// Gets the unread count.
  Future<int> get unreadMessageCount async {
    return await _module.channel.invokeMethod(
        'messageCenter#getUnreadMessageCount');
  }

  /// Enables or disables showing the OOTB UI when requested to display
  Future<void> setAutoLaunch(bool enabled) async {
    return await _module.channel.invokeMethod(
        'messageCenter#setAutoLaunch', enabled);
  }

  /// Forces the inbox to refresh.
  ///
  /// This is normally not needed as the inbox will automatically refresh on
  /// foreground or when a push arrives that's associated with a message.
  Future<bool?> refreshInbox() async {
    return _module.channel.invokeMethod("messageCenter#refreshMessages");
  }

  /// Gets inbox updated event stream.
  Stream<MessageCenterUpdatedEvent> get onInboxUpdated {
    return _module
        .getEventStream("com.airship.flutter/event/message_center_updated")
        .map((dynamic value) => MessageCenterUpdatedEvent.fromJson(value));

  }

  /// Gets show inbox event stream.
  Stream<DisplayMessageCenterEvent> get onDisplay {
    return _module
        .getEventStream("com.airship.flutter/event/display_message_center")
        .map((dynamic value) => DisplayMessageCenterEvent.fromJson(value));
  }
}

