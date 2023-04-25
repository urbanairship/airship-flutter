import 'airship_module.dart';
import 'dart:convert';
import 'inbox_message.dart';

class AirshipMessageCenter {

  final AirshipModule _module;

  AirshipMessageCenter(AirshipModule module) : this._module = module;

  /// Gets the current inbox messages.
  Future<List<InboxMessage>> get inboxMessages async {
    List inboxMessages = await _module.channel.invokeMethod("messageCenter#getMessages");
    return inboxMessages.map((dynamic payload) {
      return InboxMessage.fromJson(jsonDecode(payload));
    }).toList();
  }

  /// Marks an inbox [message] as read.
  Future<void> markInboxMessageRead(InboxMessage message) async {
    return await _module.channel.invokeMethod(
        'messageCenter#markMessageRead', message.messageId);
  }

  /// Requests to display the Message Center.
  Future<void> display([String? messageId]) async {
    return await _module.channel.invokeMethod(
        'messageCenter#display', messageId);
  }

  /// Deletes an inbox [message].
  Future<void> deleteInboxMessage(InboxMessage message) async {
    return await _module.channel.invokeMethod(
        'messageCenter#deleteMessage', message.messageId);
  }

  /// Gets the unread count.
  Future<int> getUnreadMessageCount() async {
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
  Stream<void>? get onInboxUpdated {
    return _module.getEventStream("INBOX_UPDATED");
  }

  /// Gets show inbox event stream.
  Stream<void>? get onShowInbox {
    return _module.getEventStream("SHOW_INBOX");
  }

  /// Gets show inbox message event stream.
  Stream<String?> get onShowInboxMessage {
    return _module.getEventStream("SHOW_INBOX_MESSAGE")!
        .map((dynamic value) => jsonDecode(value) as String?);
  }
}