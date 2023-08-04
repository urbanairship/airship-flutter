
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

  const PushNotificationStatus._internal(
      this.isUserNotificationsEnabled, this.areNotificationsAllowed, this.isPushPrivacyFeatureEnabled,
      this.isPushTokenRegistered, this.isOptedIn, this.isUserOptedIn);

  static PushNotificationStatus fromJson(Map<String, dynamic> json) {
    var isUserNotificationsEnabled = json["isUserNotificationsEnabled"] ?? false;
    var areNotificationsAllowed = json["areNotificationsAllowed"] ?? false;
    var isPushPrivacyFeatureEnabled = json["isPushPrivacyFeatureEnabled"] ?? false;
    var isPushTokenRegistered = json["isPushTokenRegistered"] ?? false;
    var isOptedIn = json["isOptedIn"] ?? false;
    var isUserOptedIn = json["isUserOptedIn"] ?? false;
    return PushNotificationStatus._internal(
        isUserNotificationsEnabled, areNotificationsAllowed, isPushPrivacyFeatureEnabled,
        isPushTokenRegistered, isOptedIn, isUserOptedIn);
  }

  @override
  String toString() {
    return "PushNotificationStatus(isUserNotificationsEnabled=$isUserNotificationsEnabled,"
        " areNotificationsAllowed=$areNotificationsAllowed, isPushPrivacyFeatureEnabled=$isPushPrivacyFeatureEnabled,"
        " isPushTokenRegistered=$isPushTokenRegistered, isOptedIn=$isOptedIn, isUserOptedIn=$isUserOptedIn)";
  }
}