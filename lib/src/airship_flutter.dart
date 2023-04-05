import 'dart:async';
import 'package:airship_flutter/airship_flutter.dart';

import 'airship_module.dart';

/// The Main Airship API.
class Airship {

  static final _module = AirshipModule();
  static final channel = AirshipChannel(_module);
  static final push = AirshipPush(_module);
  static final contact = AirshipContact(_module);
  // static const inApp = AirshipInApp(module);
  // static const messageCenter = AirshipMessageCenter(module);
  // static const privacyManager = AirshipPrivacyManager(module);
  // static const preferenceCenter = AirshipPreferenceCenter(module);
  // static const locale = AirshipLocale(module);
  static final analytics = AirshipAnalytics(_module);
  static final actions = AirshipActions(_module);
  //
  /// Initializes Airship with an [appKey] and [appSecret].
  ///
  /// Returns true if Airship has been initialized, otherwise returns false.
  static Future<bool> takeOff(AirshipConfig config) async {
    return await _module.channel.invokeMethod('takeOff', config.toJson());
  }

  //
  // /// Gets deep link event stream.
  // static Stream<String?> get onDeepLink {
  //   return _getEventStream("DEEP_LINK")!
  //       .map((dynamic value) => jsonDecode(value) as String?);
  // }
}
