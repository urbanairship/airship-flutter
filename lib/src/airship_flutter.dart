import 'dart:async';
import 'dart:convert';
import 'package:airship_flutter/airship_flutter.dart';

import 'airship_module.dart';

/// The Main Airship API.
class Airship {

  static final _module = AirshipModule();
  static final channel = AirshipChannel(_module);
  static final push = AirshipPush(_module);
  static final contact = AirshipContact(_module);
  static final inApp = AirshipInApp(_module);
  static final messageCenter = AirshipMessageCenter(_module);
  static final privacyManager = AirshipPrivacyManager(_module);
  static final preferenceCenter = AirshipPreferenceCenter(_module);
  static final locale = AirshipLocale(_module);
  static final analytics = AirshipAnalytics(_module);
  static final actions = AirshipActions(_module);
  //
  /// Initializes Airship with an [appKey] and [appSecret].
  ///
  /// Returns true if Airship has been initialized, otherwise returns false.
  static Future<bool> takeOff(AirshipConfig config) async {
    return await _module.channel.invokeMethod('takeOff', config.toJson());
  }

  /// Gets deep link event stream.
  static Stream<String?> get onDeepLink {
    return _module.getEventStream("DEEP_LINK")!
        .map((dynamic value) => jsonDecode(value) as String?);
  }
}
