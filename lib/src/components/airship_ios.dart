import 'package:flutter/services.dart';

/// IOS namespace
class AirshipIOS {
  static const MethodChannel _channel =
  const MethodChannel('com.airship.flutter/airship');
  /// Checks if auto-badging is enabled on iOS. Badging is not supported for Android.
  static Future<bool> isAutoBadgeEnabled() async {
    return await _channel.invokeMethod('isAutoBadgeEnabled');
  }

  /// Enables or disables auto-badging on iOS. Badging is not supported for Android.
  static Future<void> setAutoBadgeEnabled(bool enabled) async {
    return await _channel.invokeMethod('setAutoBadgeEnabled', enabled);
  }

  /// Sets the [badge] number on iOS. Badging is not supported for Android.
  static Future<void> setBadge(int badge) async {
    return await _channel.invokeMethod('setBadge', badge);
  }

  /// Clears the badge on iOS. Badging is not supported for Android.
  static Future<void> resetBadge() async {
    return await _channel.invokeMethod('resetBadge');
  }
}
