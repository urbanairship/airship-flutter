import 'package:flutter_test/flutter_test.dart';
import 'package:airship_flutter/src/push_notification_status.dart';

void main() {
  Map<String, dynamic> baseJson(String? status) => {
        "isUserNotificationsEnabled": true,
        "areNotificationsAllowed": true,
        "isPushPrivacyFeatureEnabled": true,
        "isPushTokenRegistered": true,
        "isOptedIn": true,
        "isUserOptedIn": true,
        "notificationPermissionStatus": status,
      };

  test('parses "granted" from native (snake-case string)', () {
    final status = PushNotificationStatus.fromJson(baseJson("granted"));
    expect(status.notificationPermissionStatus, PermissionStatus.granted);
  });

  test('parses "denied" from native (snake-case string)', () {
    final status = PushNotificationStatus.fromJson(baseJson("denied"));
    expect(status.notificationPermissionStatus, PermissionStatus.denied);
  });

  test('parses "not_determined" from native (snake-case string)', () {
    final status = PushNotificationStatus.fromJson(baseJson("not_determined"));
    expect(status.notificationPermissionStatus, PermissionStatus.notDetermined);
  });

  test('falls back to notDetermined when value is null', () {
    final status = PushNotificationStatus.fromJson(baseJson(null));
    expect(status.notificationPermissionStatus, PermissionStatus.notDetermined);
  });

  test('falls back to notDetermined for unknown values', () {
    final status = PushNotificationStatus.fromJson(baseJson("garbage"));
    expect(status.notificationPermissionStatus, PermissionStatus.notDetermined);
  });
}
