import 'feature.dart';
import 'airship_utils.dart';

class AirshipConfig {

  /// Default environment.
  ConfigEnvironment? defaultEnvironment;

  /// Development environment.
  ConfigEnvironment? developmentEnvironment;

  /// Production environment.
  ConfigEnvironment? productionEnvironment;

  /// Cloud site.
  Site? site;

  /// Switches the environment from development or production.
  bool? inProduction;

  /// URL allow list.
  List<String>? urlAllowList;

  /// URL allow list for open URL scope.
  List<String>? urlAllowListScopeOpenUrl;

  /// URL allow list for JS bridge injection.
  List<String>? urlAllowListScopeJavaScriptInterface;

  /// Enables delayed channel creation.
  bool? isChannelCreationDelayEnabled;

  /// Initial config URL for custom Airship domains. The URL
  /// should also be added to the urlAllowList.
  String? initialConfigUrl;

  /// Enabled features. Defaults to all.
  List<Feature>? enabledFeatures;

  /// Enables channel capture feature. Enabled by default.
  bool? isChannelCaptureEnabled;

  /// Whether to suppress console error messages
  /// about missing allow list entries during takeOff.
  /// Disabled by default.
  bool? suppressAllowListError;

  /// Pauses In-App Automation on launch.
  bool? autoPauseInAppAutomationOnLaunch;

  /// iOS config.
  IOSConfig? iosConfig;

  /// Android config.
  AndroidConfig? androidConfig;

  AirshipConfig();

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
      "enabledFeatures": enabledFeatures == null ? null : AirshipUtils.toFeatureStringList(enabledFeatures!),
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

  ConfigEnvironment(this.appKey, this.appSecret);

  Map<String, dynamic> _toJson() {
    return {
      "appKey": appKey,
      "appSecret": appSecret
    };
  }
}

enum Site { us, eu }

class IOSConfig {
  /// iTunes ID for rate app and App Store deep links.
  String? iTunesId;

  IOSConfig(this.iTunesId);

  Map<String, dynamic> _toJson() {
    return {
      "iTunesId": iTunesId
    };
  }
}

class AndroidConfig {
  /// The app store URI.
  String? appStoreUri;

  /// The FCM app name if using multiple FCM projects.
  String? fcmFirebaseAppName;

  /// Notification config.
  NotificationConfig? notificationConfig;

  AndroidConfig(this.appStoreUri, this.fcmFirebaseAppName, this.notificationConfig);

  Map<String, dynamic> _toJson() {
    return {
      "appStoreUri": appStoreUri,
      "fcmFirebaseAppName": fcmFirebaseAppName,
      "notificationConfig": notificationConfig?._toJson()
    };
  }
}

class NotificationConfig {
  /// The icon resource name.
  String? icon;

  /// The large icon resource name.
  String? largeIcon;

  /// The default Android notification channel ID.
  String? defaultChannelId;

  /// The accent color. Must be a hex value #AARRGGBB.
  String? accentColor;

  NotificationConfig(this.icon, this.largeIcon, this.defaultChannelId, this.accentColor);

  Map<String, dynamic> _toJson() {
    return {
      "icon": icon,
      "largeIcon": largeIcon,
      "defaultChannelId": defaultChannelId,
      "accentColor": accentColor
    };
  }
}