import 'feature.dart';

class AirshipConfig {

  ConfigEnvironment? defaultEnvironment;
  ConfigEnvironment? developmentEnvironment;
  ConfigEnvironment? productionEnvironment;
  Site? site;
  bool? inProduction;
  List<String>? urlAllowList;
  List<String>? urlAllowListScopeOpenUrl;
  List<String>? urlAllowListScopeJavaScriptInterface;
  bool? isChannelCreationDelayEnabled;
  String? initialConfigUrl;
  List<Feature>? enabledFeatures;
  bool? isChannelCaptureEnabled;
  bool? suppressAllowListError;
  bool? autoPauseInAppAutomationOnLaunch;
  IOSConfig? iosConfig;
  AndroidConfig? androidConfig;

  AirshipConfig([this.defaultEnvironment,
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
      this.androidConfig]);

  Map<String, dynamic> toJson() {
    return {
      "defaultEnvironment": defaultEnvironment?._toJson(),
      "developmentEnvironment": developmentEnvironment?._toJson(),
      "productionEnvironment": productionEnvironment?._toJson(),
      "site": site?.toString(),
      "inProduction": inProduction,
      "urlAllowList": urlAllowList,
      "urlAllowListScopeOpenUrl": urlAllowListScopeOpenUrl,
      "urlAllowListScopeJavaScriptInterface": urlAllowListScopeJavaScriptInterface,
      "isChannelCreationDelayEnabled": isChannelCreationDelayEnabled,
      "initialConfigUrl": initialConfigUrl,
      "enabledFeatures": enabledFeatures,
      "isChannelCaptureEnabled": isChannelCaptureEnabled,
      "suppressAllowListError": suppressAllowListError,
      "autoPauseInAppAutomationOnLaunch": autoPauseInAppAutomationOnLaunch,
      "iosConfig": iosConfig?._toJson(),
      "androidConfig": androidConfig?._toJson(),
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
  String? iTunesId;

  IOSConfig(this.iTunesId);

  Map<String, dynamic> _toJson() {
    return {
      "iTunesId": iTunesId
    };
  }
}

class AndroidConfig {
  String? appStoreUri;
  String? fcmFirebaseAppName;
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
  String? icon;
  String? largeIcon;
  String? defaultChannelId;
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