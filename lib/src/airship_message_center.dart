import 'airship_module.dart';
import 'inbox_message.dart';
import 'airship_events.dart';

class AirshipMessageCenter {
  final AirshipModule _module;

  AirshipMessageCenter(AirshipModule module) : _module = module;

  /// Retrieves the current list of inbox messages.
  ///
  /// Returns a Future that resolves to a List of InboxMessage objects.
  Future<List<InboxMessage>> get messages async {
    List inboxMessages =
        await (_module.channel.invokeMethod("messageCenter#getMessages"));
    return inboxMessages.map((dynamic payload) {
      return InboxMessage.fromJson(payload);
    }).toList();
  }

  /// Marks a specific inbox message as read.
  ///
  /// [messageId] The unique identifier of the message to be marked as read.
  /// Returns a Future that completes when the operation is finished.
  Future<void> markRead(String messageId) async {
    return await _module.channel
        .invokeMethod('messageCenter#markMessageRead', messageId);
  }

  /// Requests to display the Message Center UI.
  ///
  /// [messageId] Optional. If provided, opens the Message Center to this specific message.
  /// Returns a Future that completes when the display request is processed.
  Future<void> display([String? messageId]) async {
    return await _module.channel
        .invokeMethod('messageCenter#display', messageId);
  }

  /// Deletes a specific inbox message.
  ///
  /// [messageId] The unique identifier of the message to be deleted.
  /// Returns a Future that completes when the deletion is finished.
  Future<void> deleteMessage(String messageId) async {
    return await _module.channel
        .invokeMethod('messageCenter#deleteMessage', messageId);
  }

  /// Retrieves the count of unread messages in the inbox.
  ///
  /// Returns a Future that resolves to an integer representing the unread count.
  Future<int> get unreadMessageCount async {
    return await _module.channel
        .invokeMethod('messageCenter#getUnreadMessageCount');
  }

  /// Configures whether the default Message Center UI should automatically launch when requested.
  ///
  /// [enabled] If true, enables auto-launch; if false, disables it.
  /// Returns a Future that completes when the setting is applied.
  Future<void> setAutoLaunchDefaultMessageCenter(bool enabled) async {
    return await _module.channel
        .invokeMethod('messageCenter#setAutoLaunch', enabled);
  }

  /// Displays the Message Center UI, overriding the auto-launch setting.
  ///
  /// This method will show the Message Center regardless of the auto-launch configuration.
  /// [messageId] Optional. If provided, opens the Message Center to this specific message.
  /// Returns a Future that completes when the Message Center is displayed.
  Future<void> showMessageCenter([String? messageId]) {
    return _module.channel
        .invokeMethod('messageCenter#showMessageCenter', messageId);
  }

  /// Displays a specific message view, overriding the auto-launch setting.
  ///
  /// This method will show the message view for a specific message, regardless of the auto-launch configuration.
  /// [messageId] The unique identifier of the message to display.
  /// Returns a Future that completes when the message view is displayed.
  Future<void> showMessageView(String messageId) {
    return _module.channel
        .invokeMethod('messageCenter#showMessageView', messageId);
  }

  /// Forces a refresh of the inbox messages.
  ///
  /// This method is typically not needed as the inbox automatically refreshes on app foreground or when a new message arrives.
  /// Returns a Future that resolves to a boolean indicating the success of the refresh operation.
  Future<bool?> refreshInbox() async {
    return _module.channel.invokeMethod("messageCenter#refreshMessages");
  }

  /// Provides a stream of events for when the inbox is updated.
  ///
  /// Returns a Stream of MessageCenterUpdatedEvent objects.
  Stream<MessageCenterUpdatedEvent> get onInboxUpdated {
    return _module
        .getEventStream("com.airship.flutter/event/message_center_updated")
        .map((dynamic value) => MessageCenterUpdatedEvent.fromJson(value));
  }

  /// Provides a stream of events for when the Message Center should be displayed.
  ///
  /// This stream will only emit events if auto-launch is disabled via setAutoLaunchDefaultMessageCenter.
  /// Returns a Stream of DisplayMessageCenterEvent objects.
  Stream<DisplayMessageCenterEvent> get onDisplay {
    return _module
        .getEventStream("com.airship.flutter/event/display_message_center")
        .map((dynamic value) => DisplayMessageCenterEvent.fromJson(value));
  }
}
