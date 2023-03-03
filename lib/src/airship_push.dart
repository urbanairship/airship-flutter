import 'airship_module.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'events.dart';
import 'notification.dart';
import 'package:flutter/foundation.dart';

class AirshipPush {

  final AirshipModule _module;
  final IOSPush iOS;
  static bool _isBackgroundHandlerSet = false;

  AirshipPush(AirshipModule module) :
        this._module = module, this.iOS = IOSPush(module);

  /// Tells if user notifications are enabled or not.
  Future<bool?> get userNotificationsEnabled async {
    return await _module.channel.invokeMethod('push#getUserNotificationsEnabled');
  }

  /// Enables or disables the user notifications.
  Future<bool?> setUserNotificationsEnabled(bool enabled) async {
    return await _module.channel.invokeMethod('push#setUserNotificationsEnabled', enabled);
  }

  /// Gets all the active notifications for the application.
  ///
  /// Supported on Android Marshmallow (23)+ and iOS 10+.
  Future<List<Notification>> get activeNotifications async {
    List notifications =
    await (_module.channel.invokeMethod('push#getActiveNotifications'));
    return notifications.map((dynamic payload) {
      return Notification.fromJson(Map<String, dynamic>.from(payload));
    }).toList();
  }

  /// Sets a background message handler.
  Future<void> setBackgroundMessageHandler(
      BackgroundMessageHandler handler) async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    if (_isBackgroundHandlerSet) {
      print("Airship background message handler already set!");
      return;
    }
    _isBackgroundHandlerSet = true;

    final isolateCallback =
    PluginUtilities.getCallbackHandle(backgroundMessageIsolateCallback)!;
    final messageCallback = PluginUtilities.getCallbackHandle(handler)!;
    await _module.channel.invokeMapMethod("startBackgroundIsolate", {
      "isolateCallback": isolateCallback.toRawHandle(),
      "messageCallback": messageCallback.toRawHandle()
    });
  }


  /// Clears a specific [notification].
  ///
  /// The [notification] parameter is the notification ID.
  /// Supported on Android and iOS 10+.
  Future<void> clearNotification(String notification) async {
    return await _module.channel.invokeMethod('push#clearNotification', notification);
  }

  /// Clears all notifications for the application.
  ///
  /// Supported on Android and iOS 10+. For older iOS devices, you can set
  /// the badge number to 0 to clear notifications.
  Future<void> clearNotifications() async {
    return await _module.channel.invokeMethod('push#clearNotifications');
  }

  /// Gets push received event stream.
  Stream<PushReceivedEvent> get onPushReceived {
    return _module.getEventStream("PUSH_RECEIVED")!
        .map((dynamic value) => PushReceivedEvent.fromJson(jsonDecode(value)));
  }

  /// Gets notification response event stream.
  Stream<NotificationResponseEvent> get onNotificationResponse {
    return _module.getEventStream("NOTIFICATION_RESPONSE")!.map((dynamic value) =>
        NotificationResponseEvent.fromJson(jsonDecode(value)));
  }

}

class IOSPush {
  final AirshipModule _module;

  IOSPush(AirshipModule module)
    : this._module = module;

  /// Checks if auto-badging is enabled on iOS. Badging is not supported for Android.
  Future<bool> isAutoBadgeEnabled() async {
    var isAutoBadgeEnabled = false;
    if (Platform.isIOS) {
      isAutoBadgeEnabled = await _module.channel.invokeMethod('push#isAutoBadgeEnabled');
    }
    return isAutoBadgeEnabled;
  }

  /// Enables or disables auto-badging on iOS. Badging is not supported for Android.
  Future<void> setAutoBadgeEnabled(bool enabled) async {
    if (Platform.isIOS) {
      return await _module.channel.invokeMethod('push#setAutoBadgeEnabled', enabled);
    } else {
      return Future.value();
    }
  }

  /// Sets the [badge] number on iOS. Badging is not supported for Android.
  Future<void> setBadge(int badge) async {
    if (Platform.isIOS) {
      return await _module.channel.invokeMethod('push#setBadge', badge);
    } else {
      return Future.value();
    }
  }

  /// Clears the badge on iOS. Badging is not supported for Android.
  Future<void> resetBadge() async {
    if (Platform.isIOS) {
      return await _module.channel.invokeMethod('push#resetBadge');
    } else {
      return Future.value();
    }
  }
}