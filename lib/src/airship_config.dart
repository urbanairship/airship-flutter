import 'feature.dart';
import 'airship_utils.dart';

class AirshipConfig {

  /// Default environment.
  final ConfigEnvironment? defaultEnvironment;

  /// Development environment.
  final ConfigEnvironment? developmentEnvironment;

  /// Production environment.
  final ConfigEnvironment? productionEnvironment;

  /// Cloud site.
  final Site? site;

  /// Switches the environment from development or production.
  final bool? inProduction;

  /// URL allow list.
  final List<String>? urlAllowList;

  /// URL allow list for open URL scope.
  final List<String>? urlAllowListScopeOpenUrl;

  /// URL allow list for JS bridge injection.
  final List<String>? urlAllowListScopeJavaScriptInterface;

  /// Enables delayed channel creation.
  final bool? isChannelCreationDelayEnabled;

  /// Initial config URL for custom Airship domains. The URL
  /// should also be added to the urlAllowList.
  final String? initialConfigUrl;

  /// Enabled features. Defaults to all.
  final List<Feature>? enabledFeatures;

  /// Enables channel capture feature. Enabled by default.
  final bool? isChannelCaptureEnabled;

  /// Whether to suppress console error messages
  /// about missing allow list entries during takeOff.
  /// Disabled by default.
  final bool? suppressAllowListError;

  /// Pauses In-App Automation on launch.
  final bool? autoPauseInAppAutomationOnLaunch;

  /// iOS config.
  final IOSConfig? iosConfig;

  /// Android config.
  final AndroidConfig? androidConfig;

  AirshipConfig({this.defaultEnvironment,
    this.developmentEnvironment,
    this.productionEnvironment,
    this.site,
    this.inProduction,
    this.urlAllowList,
    this.urlAllowListScopeOpenUrl,
    this.urlAllowListScopeJavaScriptInterface,
    this.isChannelCreationDelayEnabled,
    this.initialConfigUrl,
    this.enabledFeatures,
    this.isChannelCaptureEnabled,
    this.suppressAllowListError,
    this.autoPauseInAppAutomationOnLaunch,
    this.iosConfig,
    this.androidConfig});

  Map<String, dynamic> toJson() {
    return {
      "default": defaultEnvironment?._toJson(),
      "development": developmentEnvironment?._toJson(),
      "production": productionEnvironment?._toJson(),
      "site": site?.name,
      "inProduction": inProduction,
      "urlAllowList": urlAllowList,
      "urlAllowListScopeOpenUrl": urlAllowListScopeOpenUrl,
      "urlAllowListScopeJavaScriptInterface": urlAllowListScopeJavaScriptInterface,
      "isChannelCreationDelayEnabled": isChannelCreationDelayEnabled,
      "initialConfigUrl": initialConfigUrl,
      "enabledFeatures": enabledFeatures == null ? null : AirshipUtils
          .toFeatureStringList(enabledFeatures!),
      "isChannelCaptureEnabled": isChannelCaptureEnabled,
      "autoPauseInAppAutomationOnLaunch": autoPauseInAppAutomationOnLaunch,
      "ios": iosConfig?._toJson(),
      "android": androidConfig?._toJson(),
    };
  }
}

class ConfigEnvironment {

  final String appKey;
  final String appSecret;
  final LogLevel? logLevel;
  final IOSEnvironment? ios;

  ConfigEnvironment({required this.appKey, required this.appSecret, this.logLevel, this.ios});

  Map<String, dynamic> _toJson() {
    return {
      "appKey": appKey,
      "appSecret": appSecret,
      "logLevel": logLevel?.name,
      "ios": ios?._toJson()
    };
  }
}

class IOSEnvironment {
  final LogPrivacyLevel? logPrivacyLevel;

  IOSEnvironment({this.logPrivacyLevel});

  Map<String, dynamic> _toJson() {
    return {
      "logPrivacyLevel": logPrivacyLevel?.name
    };
  }
}

enum LogPrivacyLevel {
  private,
  public
}

enum LogLevel {
  verbose,
  debug,
  info,
  warning,
  error,
  none
}

enum Site {
  us,
  eu
}

class IOSConfig {
  /// iTunes ID for rate app and App Store deep links.
  final String? iTunesId;

  IOSConfig({this.iTunesId});

  Map<String, dynamic> _toJson() {
    return {
      "iTunesId": iTunesId
    };
  }
}

class AndroidConfig {
  /// The app store URI.
  final String? appStoreUri;

  /// The FCM app name if using multiple FCM projects.
  final String? fcmFirebaseAppName;

  /// Notification config.
  final AndroidNotificationConfig? notificationConfig;

  AndroidConfig({this.appStoreUri, this.fcmFirebaseAppName,
      this.notificationConfig});

  Map<String, dynamic> _toJson() {
    return {
      "appStoreUri": appStoreUri,
      "fcmFirebaseAppName": fcmFirebaseAppName,
      "notificationConfig": notificationConfig?._toJson()
    };
  }
}

class AndroidNotificationConfig {
  /// The icon resource name.
  final String? icon;

  /// The large icon resource name.
  final String? largeIcon;

  /// The default Android notification channel ID.
  final String? defaultChannelId;

  /// The accent color. Must be a hex value #AARRGGBB.
  final String? accentColor;

  AndroidNotificationConfig({this.icon, this.largeIcon, this.defaultChannelId,
      this.accentColor});

  Map<String, dynamic> _toJson() {
    return {
      "icon": icon,
      "largeIcon": largeIcon,
      "defaultChannelId": defaultChannelId,
      "accentColor": accentColor
    };
  }
}