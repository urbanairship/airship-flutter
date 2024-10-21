/// Push notification status object.
class PushNotificationStatus {
  /// If user notifications are enabled.
  final bool isUserNotificationsEnabled;

  /// If notifications are allowed at the system level for the application.
  final bool areNotificationsAllowed;

  /// If the push feature is enabled on PrivacyManager.
  final bool isPushPrivacyFeatureEnabled;

  /// If push registration was able to generate a token.
  final bool isPushTokenRegistered;

  /// If Airship is able to send and display a push notification.
  final bool isOptedIn;

  /// Checks for isUserNotificationsEnabled, areNotificationsAllowed, and isPushPrivacyFeatureEnabled. If this flag
  /// is true but `isOptedIn` is false, that means push token was not able to be registered.
  final bool isUserOptedIn;

  /// The notification permission status.
  final PermissionStatus notificationPermissionStatus;

  const PushNotificationStatus._internal(
      this.isUserNotificationsEnabled,
      this.areNotificationsAllowed,
      this.isPushPrivacyFeatureEnabled,
      this.isPushTokenRegistered,
      this.isOptedIn,
      this.isUserOptedIn,
      this.notificationPermissionStatus);

  static PushNotificationStatus fromJson(dynamic json) {
    var isUserNotificationsEnabled =
        json["isUserNotificationsEnabled"] ?? false;
    var areNotificationsAllowed = json["areNotificationsAllowed"] ?? false;
    var isPushPrivacyFeatureEnabled =
        json["isPushPrivacyFeatureEnabled"] ?? false;
    var isPushTokenRegistered = json["isPushTokenRegistered"] ?? false;
    var isOptedIn = json["isOptedIn"] ?? false;
    var isUserOptedIn = json["isUserOptedIn"] ?? false;
    var notificationPermissionStatus =
        json["notificationPermissionStatus"] ?? PermissionStatus.notDetermined;
    return PushNotificationStatus._internal(
        isUserNotificationsEnabled,
        areNotificationsAllowed,
        isPushPrivacyFeatureEnabled,
        isPushTokenRegistered,
        isOptedIn,
        isUserOptedIn,
        notificationPermissionStatus);
  }

  @override
  String toString() {
    return "PushNotificationStatus(isUserNotificationsEnabled=$isUserNotificationsEnabled,"
        " areNotificationsAllowed=$areNotificationsAllowed, isPushPrivacyFeatureEnabled=$isPushPrivacyFeatureEnabled,"
        " isPushTokenRegistered=$isPushTokenRegistered, isOptedIn=$isOptedIn, isUserOptedIn=$isUserOptedIn, notificationPermissionStatus=$notificationPermissionStatus)";
  }
}

/// Enum of permission status.
enum PermissionStatus {
  /// Permission is granted.
  granted,

  /// Permission is denied.
  denied,

  /// Permission has not yet been requested.
  notDetermined,
}

/// Fallback when prompting for permission and the permission is
/// already denied on iOS or is denied silently on Android.
enum PromptPermissionFallback {
  // Take the user to the system settings to enable the permission.
  systemSettings,
}

/// Options for enabling push notifications.
class EnableUserPushNotificationsArgs {
  /// Optional fallback strategy.
  final PromptPermissionFallback? fallback;

  /// Creates a new instance of [EnableUserPushNotificationsArgs].
  ///
  /// Both [fallback] and [options] are optional.
  EnableUserPushNotificationsArgs({
    this.fallback,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};

    if (fallback != null) {
      json['fallback'] = fallback!.name;
    }

    return json;
  }
}
