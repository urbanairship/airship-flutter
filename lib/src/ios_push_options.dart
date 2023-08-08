/// Enum of notification options. iOS only.
enum IOSNotificationOption {
  alert,
  sound,
  badge,
  carPlay,
  criticalAlert,
  providesAppNotificationSettings,
  provisional
}

/// Enum of foreground notification options. 
enum IOSForegroundPresentationOption {
  sound,
  badge,
  list,
  banner
}

/// Enum of authorized notification options.
enum IOSAuthorizedNotificationSetting {
  alert,
  sound,
  badge,
  carPlay,
  lockScreen,
  notificationCenter,
  criticalAlert,
  announcement,
  scheduledDelivery,
  timeSensitive
}

/// Enum of authorized status.
enum IOSAuthorizedNotificationStatus {
  notDetermined,
  denied,
  authorized,
  provisional,
  ephemeral
}
