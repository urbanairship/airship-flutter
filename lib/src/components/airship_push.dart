import 'package:flutter/services.dart';

/// Push notification object.
class Notification {
  /// The notification ID.
  final String? notificationId;

  /// The notification alert.
  final String? alert;

  /// The notification title.
  final String? title;

  /// The notification subtitle.
  final String? subtitle;

  /// The notification extras.
  final Map<String, dynamic>? extras;

  const Notification._internal(
      this.notificationId, this.alert, this.title, this.subtitle, this.extras);

  static Notification fromJson(Map<String, dynamic> json) {
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

/// Push name
class AirshipPush {
  static const MethodChannel _channel =
      const MethodChannel('com.airship.flutter/airship');

  ///  Disables the user notifications.
  Future<bool> get disableUserNotifications async {
    return setUserNotificationsEnabled(false);
  }

  /// Enables the user notifications.
  Future<bool> get enableUserNotifications async {
    return setUserNotificationsEnabled(true);
  }

  /// Enables the user notifications.
  Future<bool> setUserNotificationsEnabled(final bool enabled) async {
    return await _channel.invokeMethod('setUserNotificationsEnabled', enabled);
  }

  /// Tells if user notifications are enabled or not.
  Future<bool> get userNotificationsEnabled async {
    return await _channel.invokeMethod('getUserNotificationsEnabled') ?? false;
  }

  /// push token
  Future<String> get pushToken async {
    return await _channel.invokeMethod('getPushToken');
  }

  /// Clears a specific [notification].
  ///
  /// The [notification] parameter is the notification ID.
  /// Supported on Android and iOS 10+.
  Future<void> clearNotification(String notification) async {
    return await _channel.invokeMethod('clearNotification', notification);
  }

  /// Clears all notifications for the application.
  ///
  /// Supported on Android and iOS 10+. For older iOS devices, you can set
  /// the badge number to 0 to clear notifications.
  Future<void> clearNotifications() async {
    return await _channel.invokeMethod('clearNotifications');
  }

  /// Gets all the active notifications for the application.
  ///
  /// Supported on Android Marshmallow (23)+ and iOS 10+.
  Future<List<Notification>> get activeNotifications async {
    List notifications =
        await (_channel.invokeMethod('getActiveNotifications'));
    return notifications.map((dynamic payload) {
      return Notification.fromJson(Map<String, dynamic>.from(payload));
    }).toList();
  }
}
