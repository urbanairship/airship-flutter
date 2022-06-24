import 'package:airship_flutter/airship_flutter.dart';

abstract class Config {
  static AirshipConfig airship = AirshipConfig(
      development: AirshipEnv(
        /// Add your appKey
          appKey: "",
          /// Add your appSecret
          appSecret: "",
          logLevel: LogLevel.DEBUG),
      android: AndroidConfig(
          notification: AndroidNotificationConfig(
              defaultChannelId: "customChannel",
              icon: "",
              accentColor: "#ffff0000",
              )),
      urlAllowList: ["*"],
      urlAllowListScopeOpenUrl: ["*"],
      inProduction: false);
}
