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
  Future<bool?> get isUserNotificationsEnabled async {
    return await _module.channel.invokeMethod('push#isUserNotifictionsEnabled');
  }

  /// Enables or disables the user notifications.
  Future<bool?> setUserNotificationsEnabled(bool enabled) async {
    return await _module.channel.invokeMethod('push#setUserNotificationsEnabled', enabled);
  }

  /// Enables user notifications.
  Future<bool?> enableUserNotifications() async {
    return await _module.channel.invokeMethod('push#enableUserNotifications');
  }

  /// Gets the notification status.
  Future<bool?> getNotificationStatus() async {
    return await _module.channel.invokeMethod('push#getNotificationStatus');
  }

  /// Gets the registration token if generated.
  Future<String?> getRegistrationToken() async {
    return await _module.channel.invokeMethod('push#getRegistrationToken');
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
    return _module.getEventStream("PUSH_RECEIVED")
        .map((dynamic value) => PushReceivedEvent.fromJson(jsonDecode(value)));
  }

  /// Gets notification response event stream.
  Stream<NotificationResponseEvent> get onNotificationResponse {
    return _module.getEventStream("NOTIFICATION_RESPONSE").map((dynamic value) =>
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
      isAutoBadgeEnabled = await _module.channel.invokeMethod('push#ios#isAutobadgeEnabled');
    }
    return isAutoBadgeEnabled;
  }

  /// Sets the notification options.
  Future<void> setNotificationOptions(List<NotificationOption> options) async {
    if (Platform.isIOS) {
      var parsedOptions = List<NotificationOption>.from(options)
          .map((option) => option.toString())
          .toList();
      return await _module.channel.invokeMethod('push#ios#setNotificationOptions', parsedOptions);
    } else {
      return Future.value();
    }
  }

  /// Sets the notification options.
  Future<void> setForegroundPresentationOptions(List<ForegroundPresentationOption> options) async {
    if (Platform.isIOS) {
      var parsedOptions = List<ForegroundPresentationOption>.from(options)
          .map((option) => option.toString())
          .toList();
      return await _module.channel.invokeMethod('push#ios#setForegroundPresentationOptions', options);
    } else {
      return Future.value();
    }
  }

  /// Enables or disables auto-badging on iOS. Badging is not supported for Android.
  Future<void> setAutoBadgeEnabled(bool enabled) async {
    if (Platform.isIOS) {
      return await _module.channel.invokeMethod('push#ios#setAutobadgeEnabled', enabled);
    } else {
      return Future.value();
    }
  }

  /// Sets the [badge] number on iOS. Badging is not supported for Android.
  Future<void> setBadge(int badge) async {
    if (Platform.isIOS) {
      return await _module.channel.invokeMethod('push#ios#setBadgeNumber', badge);
    } else {
      return Future.value();
    }
  }

  /// Gets the [badge] number on iOS. Badging is not supported for Android.
  Future<int> get badge async {
    if (Platform.isIOS) {
      return await _module.channel.invokeMethod('push#ios#getBadgeNumber');
    } else {
      return Future.value(0);
    }
  }

  /// Clears the badge on iOS. Badging is not supported for Android.
  Future<void> resetBadge() async {
    if (Platform.isIOS) {
      return await _module.channel.invokeMethod('push#ios#resetBadgeNumber');
    } else {
      return Future.value();
    }
  }
}

enum NotificationOption { alert, sound, badge, car_play, critical_alert, provides_app_notification_settings, provisional }

enum ForegroundPresentationOption { sound, badge, list, banner }