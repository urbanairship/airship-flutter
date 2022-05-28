import 'package:flutter/cupertino.dart';

enum LogLevel { VERBOSE, DEBUG, INFO, WARN, ERROR, ASSERT }
enum Site { us, eu }

/// Enum of authorized/enabled Features.
enum Feature {
  //FEATURE_NONE
  NONE,
  //FEATURE_IN_APP_AUTOMATION
  IN_APP_AUTOMATION,
  //FEATURE_MESSAGE_CENTER
  MESSAGE_CENTER,
  //FEATURE_PUSH
  PUSH,
  //FEATURE_CHAT
  CHAT,
  //FEATURE_ANALYTICS
  ANALYTICS,
  //FEATURE_TAGS_AND_ATTRIBUTES
  TAGS_AND_ATTRIBUTES,
  //FEATURE_CONTACTS
  CONTACTS,
  //FEATURE_LOCATION
  LOCATION,
  //FEATURE_ALL
  ALL,
}

class AirshipApp {
  /// App key.
  final String key;

  /// App secret.
  final String secret;

  /// Optional log level.
  final LogLevel logLevel;

  const AirshipApp({
    required this.key,
    required this.secret,
    required this.logLevel,
  });

  Map<String, String> toArgs() => {
      "app_key": this.key,
      "app_secret": this.secret,
      "log_level": this.logLevel.name,
    };
}

/// Android notification config.
class AndroidNotificationConfig {
  /// The icon resource name.
  final String icon;

  /// The large icon resource name.
  final String largeIcon;

  /// The accent color.
  /// Must be a hex value #AARRGGBB.
  /// Provide it as Color in flutter
  final Color accentColor;

  /// The default android notification channel ID.
  final String defaultChannelId;

  const AndroidNotificationConfig({
    this.icon = "ic_notification",
    this.largeIcon = "ic_large_notification",
    this.accentColor = const Color(0xffefd6da),
    required this.defaultChannelId,
  });
}

/// iOS config.
class IOSConfig {
  /// itunesId for rate app and app store deep links.
  final String itunesId;

  const IOSConfig(this.itunesId);
}

/// Android specific config.
class AndroidConfig {
  /// App store URI
  final String appStoreUri;

  /// Fcm app name if using multiple FCM projects.
  final String fcmFirebaseAppName;

  /// Notification config.
  final AndroidNotificationConfig notificationConfigAndroid;

  AndroidConfig({
    required this.appStoreUri,
    required this.fcmFirebaseAppName,
    required this.notificationConfigAndroid,
  });
}

/// Chat config. Only needed with the chat module.
class ChatConfig {
  final String webSocketUrl;
  final String url;

  const ChatConfig({required this.webSocketUrl, required this.url});
}

class AirshipConfig {
  final AirshipApp production;

  /// Development environment.
  /// Overrides default environment if [inProduction] is false.
  final AirshipApp development;

  /// Production environment.
  /// Overrides default environment if [inProduction] is true.
  final AndroidNotificationConfig notification;

  /// Switches the environment from development or production.
  /// If the value is not set,
  /// Airship will determine the value at runtime.
  final bool inProduction;

  /// Cloud site.
  final Site site;

  /// URL allow list.
  final List<String> urlAllowList;

  /// URL allow list for open URL scope.
  final List<String> urlAllowListScopeOpenUrl;

  /// URL allow list for JS bridge injection.
  final List<String> urlAllowListScopeJavaScriptInterface;

  /// Enables delayed channel creation.
  final bool isChannelCreationDelayEnabled;

  /// Enables/disables requiring initial remote config fetch before
  /// creating a channel.
  final bool requireInitialRemoteConfigEnabled;

  /// Enabled features. Defaults to all.
  final List<Feature> enabledFeatures;

  /// Chat config. Only needed with the chat module.
  final ChatConfig chat;

  /// iOS config.
  final IOSConfig ios;

  const AirshipConfig({
    required this.production,
    required this.development,
    required this.inProduction,
    required this.notification,
    required this.site,
    required this.urlAllowList,
    required this.urlAllowListScopeOpenUrl,
    required this.urlAllowListScopeJavaScriptInterface,
    required this.isChannelCreationDelayEnabled,
    required this.requireInitialRemoteConfigEnabled,
    required this.enabledFeatures,
    required this.chat,
    required this.ios,
  });
}
