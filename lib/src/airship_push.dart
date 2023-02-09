import 'airship_module.dart';

class AirshipPush {

  final AirshipModule _module;

  AirshipPush(AirshipModule module)
      : this._module = module;

  /// Tells if user notifications are enabled or not.
  Future<bool?> get userNotificationsEnabled async {
    return await _module.channel.invokeMethod('push#getUserNotificationsEnabled');
  }

  /// Enables or disables the user notifications.
  Future<bool?> setUserNotificationsEnabled(bool enabled) async {
    return await _module.channel.invokeMethod('push#setUserNotificationsEnabled', enabled);
  }

//
//
//   /// Checks if auto-badging is enabled on iOS. Badging is not supported for Android.
//   static Future<bool> isAutoBadgeEnabled() async {
//     var isAutoBadgeEnabled = false;
//     if (Platform.isIOS) {
//       isAutoBadgeEnabled = await _channel.invokeMethod('isAutoBadgeEnabled');
//     }
//     return isAutoBadgeEnabled;
//   }
//
//   /// Enables or disables auto-badging on iOS. Badging is not supported for Android.
//   static Future<void> setAutoBadgeEnabled(bool enabled) async {
//     if (Platform.isIOS) {
//       return await _channel.invokeMethod('setAutoBadgeEnabled', enabled);
//     } else {
//       return Future.value();
//     }
//   }
//
//   /// Sets the [badge] number on iOS. Badging is not supported for Android.
//   static Future<void> setBadge(int badge) async {
//     if (Platform.isIOS) {
//       return await _channel.invokeMethod('setBadge', badge);
//     } else {
//       return Future.value();
//     }
//   }
//
//   /// Clears the badge on iOS. Badging is not supported for Android.
//   static Future<void> resetBadge() async {
//     if (Platform.isIOS) {
//       return await _channel.invokeMethod('resetBadge');
//     } else {
//       return Future.value();
//     }
//   }
//

//
//   /// Gets all the active notifications for the application.
//   ///
//   /// Supported on Android Marshmallow (23)+ and iOS 10+.
//   static Future<List<Notification>> get activeNotifications async {
//     List notifications =
//     await (_channel.invokeMethod('getActiveNotifications'));
//     return notifications.map((dynamic payload) {
//       return Notification._fromJson(Map<String, dynamic>.from(payload));
//     }).toList();
//   }
//
//   /// Sets a background message handler.
//   static Future<void> setBackgroundMessageHandler(
//       BackgroundMessageHandler handler) async {
//     if (defaultTargetPlatform != TargetPlatform.android) {
//       return;
//     }
//     if (_isBackgroundHandlerSet) {
//       print("Airship background message handler already set!");
//       return;
//     }
//     _isBackgroundHandlerSet = true;
//
//     final isolateCallback =
//     PluginUtilities.getCallbackHandle(_backgroundMessageIsolateCallback)!;
//     final messageCallback = PluginUtilities.getCallbackHandle(handler)!;
//     await _channel.invokeMapMethod("startBackgroundIsolate", {
//       "isolateCallback": isolateCallback.toRawHandle(),
//       "messageCallback": messageCallback.toRawHandle()
//     });
//   }
//

//
//   /// Clears a specific [notification].
//   ///
//   /// The [notification] parameter is the notification ID.
//   /// Supported on Android and iOS 10+.
//   static Future<void> clearNotification(String notification) async {
//     return await _channel.invokeMethod('clearNotification', notification);
//   }
//
//   /// Clears all notifications for the application.
//   ///
//   /// Supported on Android and iOS 10+. For older iOS devices, you can set
//   /// the badge number to 0 to clear notifications.
//   static Future<void> clearNotifications() async {
//     return await _channel.invokeMethod('clearNotifications');
//   }
//
//
//   /// Gets push received event stream.
//   static Stream<PushReceivedEvent> get onPushReceived {
//     return _getEventStream("PUSH_RECEIVED")!
//         .map((dynamic value) => PushReceivedEvent._fromJson(jsonDecode(value)));
//   }
//
//   /// Gets notification response event stream.
//   static Stream<NotificationResponseEvent> get onNotificationResponse {
//     return _getEventStream("NOTIFICATION_RESPONSE")!.map((dynamic value) =>
//         NotificationResponseEvent._fromJson(jsonDecode(value)));
//   }
//
}