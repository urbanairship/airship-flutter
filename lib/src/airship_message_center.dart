// class AirshipMessageCenter {
//
//   const MethodChannel _channel;
//
//   const AirshipMessageCenter._internal(this._channel)
//
//   /// Gets the current inbox messages.
//   static Future<List<InboxMessage>> get inboxMessages async {
//     List inboxMessages = await (_channel.invokeMethod("getInboxMessages"));
//     return inboxMessages.map((dynamic payload) {
//       return InboxMessage._fromJson(jsonDecode(payload));
//     }).toList();
//   }
//
//
//   /// Marks an inbox [message] as read.
//   static Future<void> markInboxMessageRead(InboxMessage message) async {
//     return await _channel.invokeMethod(
//         'markInboxMessageRead', message.messageId);
//   }
//
//   /// Deletes an inbox [message].
//   static Future<void> deleteInboxMessage(InboxMessage message) async {
//     return await _channel.invokeMethod('deleteInboxMessage', message.messageId);
//   }
//
//   /// Forces the inbox to refresh.
//   ///
//   /// This is normally not needed as the inbox will automatically refresh on
//   /// foreground or when a push arrives that's associated with a message.
//   static Future<bool?> refreshInbox() async {
//     return _channel.invokeMethod("refreshInbox");
//   }
//
//   /// Gets inbox updated event stream.
//   static Stream<void>? get onInboxUpdated {
//     return _getEventStream("INBOX_UPDATED");
//   }
//
//   /// Gets show inbox event stream.
//   static Stream<void>? get onShowInbox {
//     return _getEventStream("SHOW_INBOX");
//   }
//
//   /// Gets show inbox message event stream.
//   static Stream<String?> get onShowInboxMessage {
//     return _getEventStream("SHOW_INBOX_MESSAGE")!
//         .map((dynamic value) => jsonDecode(value) as String?);
//   }
// }