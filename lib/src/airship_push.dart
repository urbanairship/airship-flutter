import 'airship_module.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'airship_events.dart';
import 'push_payload.dart';
import 'push_notification_status.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' hide Notification;

class AirshipPush {

  final AirshipModule _module;
  final IOSPush iOS;
  final AndroidPush android;
  static bool _isBackgroundHandlerSet = false;

  AirshipPush(AirshipModule module)
      :
        this._module = module,
        this.iOS = IOSPush(module),
        this.android = AndroidPush(module);

  /// Tells if user notifications are enabled or not.
  Future<bool> get isUserNotificationsEnabled async {
    return await _module.channel.invokeMethod(
        'push#isUserNotificationsEnabled');
  }

  /// Enables or disables the user notifications.
  Future<void> setUserNotificationsEnabled(bool enabled) async {
    return await _module.channel.invokeMethod(
        'push#setUserNotificationsEnabled', enabled);
  }

  /// Enables user notifications.
  Future<bool?> enableUserNotifications() async {
    return await _module.channel.invokeMethod('push#enableUserNotifications');
  }

  /// Gets the notification status.
  Future<PushNotificationStatus?> get notificationStatus async {
    var payload = await _module.channel.invokeMethod(
        'push#getNotificationStatus');
    return PushNotificationStatus.fromJson(Map<String, dynamic>.from(payload));
  }

  /// Gets the registration token if generated.
  Future<String?> get registrationToken async {
    return await _module.channel.invokeMethod('push#getRegistrationToken');
  }

  /// Gets all the active notifications for the application.
  ///
  /// Supported on Android Marshmallow (23)+ and iOS 10+.
  Future<List<PushPayload>> get activeNotifications async {
    List notifications =
    await (_module.channel.invokeMethod('push#getActiveNotifications'));
    return notifications.map((dynamic payload) {
      return PushPayload.fromJson(payload);
    }).toList();
  }

  /// Clears a specific [notification].
  ///
  /// The [notification] parameter is the notification ID.
  Future<void> clearNotification(String notification) async {
    return await _module.channel.invokeMethod(
        'push#clearNotification', notification);
  }

  /// Clears all notifications for the application.
  Future<void> clearNotifications() async {
    return await _module.channel.invokeMethod('push#clearNotifications');
  }

  /// Gets push received event stream.
  Stream<PushReceivedEvent> get onPushReceived {
    return _module
        .getEventStream("com.airship.flutter/event/foreground_push_received")
        .map((dynamic value) => PushReceivedEvent.fromJson(value));
  }

  /// Gets notification response event stream.
  Stream<NotificationResponseEvent> get onNotificationResponse {
    return _module
        .getEventStream("com.airship.flutter/event/notification_response")
        .map((dynamic value) => NotificationResponseEvent.fromJson(value));
  }

  /// Gets the push notification status changed event stream.
  Stream<PushNotificationStatusChangedEvent> get onNotificationStatusChanged {
    return _module
        .getEventStream("com.airship.flutter/event/notification_status_changed")
        .map((dynamic value) => PushNotificationStatusChangedEvent.fromJson(value));
  }
}

class AndroidPush {
  final AirshipModule _module;
  static bool _isBackgroundHandlerSet = false;

  AndroidPush(AirshipModule module)
      : this._module = module;

  /// Sets a background message handler.
  Future<void> setBackgroundPushReceivedHandler(
      AndroidBackgroundPushReceivedHandler handler) async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    if (_isBackgroundHandlerSet) {
      print("Airship background message handler already set!");
      return;
    }
    _isBackgroundHandlerSet = true;

    final isolateCallback =
    PluginUtilities.getCallbackHandle(_androidBackgroundMessageIsolateCallback)!;
    final messageCallback = PluginUtilities.getCallbackHandle(handler)!;
    await _module.channel.invokeMapMethod("startBackgroundIsolate", {
      "isolateCallback": isolateCallback.toRawHandle(),
      "messageCallback": messageCallback.toRawHandle()
    });
  }
}


@pragma('vm:entry-point')
void _androidBackgroundMessageIsolateCallback() {
  WidgetsFlutterBinding.ensureInitialized();

  AirshipModule.singleton.backgroundChannel.setMethodCallHandler((call) async {
    if (call.method == "onBackgroundMessage") {
      final args = call.arguments;
      final handle = CallbackHandle.fromRawHandle(args["messageCallback"]);
      final callback = PluginUtilities.getCallbackFromHandle(handle)
      as AndroidBackgroundPushReceivedHandler;
      try {
        final event = PushReceivedEvent.fromJson(args["event"]);
        await callback(event);
      } catch (e) {
        print("Airship: Failed to handle background message!");
        print(e);
      }
    } else {
      throw UnimplementedError("${call.method} is not implemented!");
    }
  });

  // Tell the native side to start the background isolate.
  AirshipModule.singleton.backgroundChannel.invokeMethod<void>("backgroundIsolateStarted");
}

class IOSPush {
  final AirshipModule _module;

  IOSPush(AirshipModule module)
      : this._module = module;

  /// Checks if auto-badging is enabled on iOS. Badging is not supported for Android.
  Future<bool> isAutoBadgeEnabled() async {
    var isAutoBadgeEnabled = false;
    if (Platform.isIOS) {
      isAutoBadgeEnabled =
      await _module.channel.invokeMethod('push#ios#isAutobadgeEnabled');
    }
    return isAutoBadgeEnabled;
  }

  /// Sets the notification options.
  Future<void> setNotificationOptions(List<IOSNotificationOption> options) async {
    if (Platform.isIOS) {
      var parsedOptions = List<IOSNotificationOption>.from(options)
          .map((option) => option.toString())
          .toList();
      return await _module.channel.invokeMethod(
          'push#ios#setNotificationOptions', parsedOptions);
    } else {
      return Future.value();
    }
  }

  /// Sets the notification options.
  Future<void> setForegroundPresentationOptions(
      List<IOSForegroundPresentationOption> options) async {
    if (Platform.isIOS) {
      var parsedOptions = List<IOSForegroundPresentationOption>.from(options)
          .map((option) => option.toString())
          .toList();
      return await _module.channel.invokeMethod(
          'push#ios#setForegroundPresentationOptions', parsedOptions);
    } else {
      return Future.value();
    }
  }

  /// Enables or disables auto-badging on iOS. Badging is not supported for Android.
  Future<void> setAutoBadgeEnabled(bool enabled) async {
    if (Platform.isIOS) {
      return await _module.channel.invokeMethod(
          'push#ios#setAutobadgeEnabled', enabled);
    } else {
      return Future.value();
    }
  }

  /// Sets the [badge] number on iOS. Badging is not supported for Android.
  Future<void> setBadge(int badge) async {
    if (Platform.isIOS) {
      return await _module.channel.invokeMethod(
          'push#ios#setBadgeNumber', badge);
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

enum IOSNotificationOption {
  alert,
  sound,
  badge,
  carPlay,
  criticalAlert,
  providesAppNotificationSettings,
  provisional
}

enum IOSForegroundPresentationOption { sound, badge, list, banner }

typedef AndroidBackgroundPushReceivedHandler = Future<void> Function(PushReceivedEvent pushReceivedEvent);
  