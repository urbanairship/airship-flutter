// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
//
// enum LogLevel { NONE, VERBOSE, DEBUG, INFO, WARN, ERROR}
// enum Site { us, eu }
//
// /// Enum of authorized/enabled Features.
// enum Feature {
//   NONE,
//   IN_APP_AUTOMATION,
//   MESSAGE_CENTER,
//   PUSH,
//   CHAT,
//   ANALYTICS,
//   TAGS_AND_ATTRIBUTES,
//   CONTACTS,
//   LOCATION,
//   ALL,
// }
//
// class AirshipAppEnv {
//   /// App key.
//   final String key;
//
//   /// App secret.
//   final String secret;
//
//   /// Optional log level.
//   final LogLevel logLevel;
//
//   const AirshipAppEnv({
//     required this.key,
//     required this.secret,
//     required this.logLevel,
//   });
//
//   Map<String, String> toJson() => {
//         "appKey": this.key,
//         "appSecret": this.secret,
//         "logLevel": this.logLevel.name,
//       };
//
//   factory AirshipAppEnv.fromJson(Map<String, dynamic> json) {
//     return AirshipAppEnv(
//       key: json["key"],
//       secret: json["secret"],
//       logLevel: LogLevel.values.byName(json["logLevel"]),
//     );
//   }
// }
//
// /// Android notification config.
// class AndroidNotificationConfig {
//   /// The icon resource name.
//   final String icon;
//
//   /// The large icon resource name.
//   final String largeIcon;
//
//   /// The accent color.
//   /// Must be a hex value #AARRGGBB.
//   /// Provide it as Color in flutter
//   final Color accentColor;
//
//   /// The default android notification channel ID.
//   final String defaultChannelId;
//
//   const AndroidNotificationConfig({
//     this.icon = "ic_notification",
//     this.largeIcon = "ic_large_notification",
//     this.accentColor = const Color(0xffefd6da),
//     required this.defaultChannelId,
//   });
//
//   Map<String, String> toJson() => {
//         "icon": this.icon,
//         "largeIcon": this.largeIcon,
//         "accentColor": this.accentColor.value.toString(),
//         "defaultChannelId": this.defaultChannelId,
//       };
//
//   factory AndroidNotificationConfig.fromJson(Map<String, dynamic> json) {
//     return AndroidNotificationConfig(
//       icon: json["icon"],
//       largeIcon: json["largeIcon"],
//       accentColor: Color(json["accentColor"] as int),
//       defaultChannelId: json["defaultChannelId"],
//     );
//   }
// //
//
// }
//
// /// iOS config.
// class IosConfig {
//   /// itunesId for rate app and app store deep links.
//   final String itunesId;
//
//   const IosConfig({this.itunesId = ""});
//
//   Map<String, String> toJson() => {
//         "itunesId": this.itunesId,
//       };
//
//   factory IosConfig.fromJson(Map<String, dynamic> json) {
//     return IOSConfig(
//       itunesId: json["itunesId"],
//     );
//   }
// //
//
// }
//
// /// Android specific config.
// class AndroidConfig {
//   /// App store URI
//   final String appStoreUri;
//
//   /// Fcm app name if using multiple FCM projects.
//   final String fcmFirebaseAppName;
//
//   /// Notification config.
//   final AndroidNotificationConfig notificationConfigAndroid;
//
//   const AndroidConfig({
//     required this.appStoreUri,
//     required this.fcmFirebaseAppName,
//     required this.notificationConfigAndroid,
//   });
//
//   Map<String, dynamic> toJson() {
//     return {
//       "appStoreUri": this.appStoreUri,
//       "fcmFirebaseAppName": this.fcmFirebaseAppName,
//       "notificationConfigAndroid": this.notificationConfigAndroid,
//     };
//   }
//
//   factory AndroidConfig.fromJson(Map<String, dynamic> json) {
//     return AndroidConfig(
//       appStoreUri: json["appStoreUri"],
//       fcmFirebaseAppName: json["fcmFirebaseAppName"],
//       notificationConfigAndroid:
//           AndroidNotificationConfig.fromJson(json["notificationConfigAndroid"]),
//     );
//   }
// //
//
// }
//
//
// class AirshipConfig {
//   final AirshipAppEnv? production;
//
//   /// Development environment.
//   /// Overrides default environment if [inProduction] is false.
//   final AirshipAppEnv? development;
//
//   /// Production environment.
//   /// Overrides default environment if [inProduction] is true.
//   final AndroidNotificationConfig? notification;
//
//   /// Switches the environment from development or production.
//   /// If the value is not set,
//   /// Airship will determine the value at runtime.
//   final bool inProduction;
//
//   /// Cloud site.
//   final Site? site;
//
//   /// URL allow list.
//   final List<String>? urlAllowList;
//
//   /// URL allow list for open URL scope.
//   final List<String>? urlAllowListScopeOpenUrl;
//
//   /// URL allow list for JS bridge injection.
//   final List<String>? urlAllowListScopeJavaScriptInterface;
//
//   /// Enables delayed channel creation.
//   final bool? isChannelCreationDelayEnabled;
//
//   /// Enables/disables requiring initial remote config fetch before
//   /// creating a channel.
//   final bool? requireInitialRemoteConfigEnabled;
//
//   /// Enabled features. Defaults to all.
//   final List<Feature>? enabledFeatures;
//
//
//   /// iOS config.
//   final IOSConfig? ios;
//   final AirshipAppEnv? defaultEnv;
//
//   const AirshipConfig({
//     this.defaultEnv,
//     this.production,
//     this.development,
//     this.inProduction = kReleaseMode || kProfileMode,
//     this.notification,
//     this.site,
//     this.urlAllowList,
//     this.urlAllowListScopeOpenUrl,
//     this.urlAllowListScopeJavaScriptInterface,
//     this.isChannelCreationDelayEnabled,
//     this.requireInitialRemoteConfigEnabled,
//     this.enabledFeatures,
//     this.ios,
//   });
//
//   AirshipAppEnv? get _production {
//     if (production == null && defaultEnv != null && inProduction) {
//       return AirshipAppEnv(
//         key: defaultEnv!.key,
//         secret: defaultEnv!.secret,
//         logLevel: LogLevel.ERROR,
//       );
//     }
//     return production;
//   }
//
//   AirshipAppEnv? get _development {
//     if (development == null && defaultEnv != null && kDebugMode) {
//       return AirshipAppEnv(
//         key: defaultEnv!.key,
//         secret: defaultEnv!.secret,
//         logLevel: LogLevel.DEBUG,
//       );
//     }
//     return development;
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       "production": _production?.toJson(),
//       "development": _development?.toJson(),
//       "notification": this.notification?.toJson(),
//       "inProduction": this.inProduction,
//       "site": this.site?.name,
//       "urlAllowList": this.urlAllowList,
//       "urlAllowListScopeOpenUrl": this.urlAllowListScopeOpenUrl,
//       "urlAllowListScopeJavaScriptInterface":
//           this.urlAllowListScopeJavaScriptInterface,
//       "isChannelCreationDelayEnabled": this.isChannelCreationDelayEnabled,
//       "requireInitialRemoteConfigEnabled":
//           this.requireInitialRemoteConfigEnabled,
//       "enabledFeatures": this.enabledFeatures?.map((e) => e.name).toList(),
//       "ios": this.ios?.toJson(),
//     }.entries.fold(<String, dynamic>{}, _removeUnsetProperties);
//   }
//
//   /// todo make it <String,String>{}
//   Map<String, dynamic> _removeUnsetProperties(
//       final previousValue, MapEntry<String, Object?> element) {
//     if (element.value != null) {
//       return {...previousValue, element.key: element.value};
//     }
//     return previousValue;
//   }
//
//   factory AirshipConfig.fromJson(Map<String, dynamic> json) {
//     return AirshipConfig(
//       production: AirshipAppEnv.fromJson(json["production"]),
//       development: AirshipAppEnv.fromJson(json["development"]),
//       notification: AndroidNotificationConfig.fromJson(json["notification"]),
//       inProduction: json["inProduction"].toLowerCase() == 'true',
//       site: Site.values.byName(json["site"]),
//       urlAllowList: List.from(json["urlAllowList"]),
//       urlAllowListScopeOpenUrl: List.from(json["urlAllowListScopeOpenUrl"]),
//       urlAllowListScopeJavaScriptInterface:
//           List.from(json["urlAllowListScopeJavaScriptInterface"]),
//       isChannelCreationDelayEnabled:
//           json["isChannelCreationDelayEnabled"].toLowerCase() == 'true',
//       requireInitialRemoteConfigEnabled:
//           json["requireInitialRemoteConfigEnabled"].toLowerCase() == 'true',
//       enabledFeatures: List.from(json["enabledFeatures"]),
//       ios: IosSConfig.fromJson(json["ios"]),
//       defaultEnv: AirshipAppEnv.fromJson(json["defaultEnv"]),
//     );
//   }
// //
//
// }
