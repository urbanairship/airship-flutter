
/// Push object.
class PushPayload {
  /// The notification ID.
  final String? notificationId;

  /// The notification alert.
  final String? alert;

  /// The notification title.
  final String? title;

  /// The notification subtitle.
  final String? subtitle;

  /// The notification extras.
  final Map<String, dynamic> extras;

  const PushPayload._internal(
      this.notificationId, this.alert, this.title, this.subtitle, this.extras);

  static PushPayload fromJson(dynamic json) {
    var notificationId = json["notificationId"];
    var alert = json["alert"];
    var title = json["title"];
    var subtitle = json["subtitle"];
    var extras;
    if (json["extras"] != null) {
      extras = Map<String, dynamic>.from(json["extras"]);
    }
    return PushPayload._internal(
        notificationId, alert, title, subtitle, extras);
  }

  @override
  String toString() {
    return "PushPayload(notificationId=$notificationId, alert=$alert, title=$title, subtitle=$subtitle, extras=$extras)";
  }
}