/// Inbox message object.
class InboxMessage {
  /// The message title.
  final String title;

  /// The message ID. Needed to display, mark as read, or delete the message.
  final String messageId;

  /// The message sent date in milliseconds.
  final int sentDate;

  /// The message expiration date in milliseconds.
  final int? expirationDate;

  /// Optional - The icon url for the message.
  final String? listIcon;

  /// The unread / read status of the message.
  final bool isRead;

  /// String to String map of any message extras.
  final Map<String, Object?>? extras;

  const InboxMessage._internal(this.title, this.messageId, this.sentDate,
      this.expirationDate, this.listIcon, this.isRead, this.extras);

  static InboxMessage fromJson(dynamic json) {
    var title = json["title"];
    var messageId = json["id"];
    var sentDate = json["sentDate"];
    var expirationDate = json["expirationDate"];
    var listIcon = json["listIconUrl"];
    var isRead = json["isRead"];
    var extras = Map<String, Object?>.from(json["extras"]);
    return InboxMessage._internal(
        title, messageId, sentDate, expirationDate, listIcon, isRead, extras);
  }

  @override
  String toString() {
    return "InboxMessage(title=$title, messageId=$messageId)";
  }
}
