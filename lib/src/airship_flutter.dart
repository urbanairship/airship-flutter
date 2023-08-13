import 'dart:async';
import 'package:airship_flutter/airship_flutter.dart';
import 'airship_module.dart';

/// The Main Airship API.
class Airship {

  static final _module = AirshipModule();

  /// The [AirshipChannel] instance.
  static final channel = AirshipChannel(_module);
  /// The [AirshipPush] instance.
  static final push = AirshipPush(_module);
  /// The [AirshipContact] instance.
  static final contact = AirshipContact(_module);
  /// The [AirshipInApp] instance.
  static final inApp = AirshipInApp(_module);
  /// The [AirshipMessageCenter] instance.
  static final messageCenter = AirshipMessageCenter(_module);
  /// The [AirshipPrivacyManager] instance.
  static final privacyManager = AirshipPrivacyManager(_module);
  /// The [AirshipPreferenceCenter] instance.
  static final preferenceCenter = AirshipPreferenceCenter(_module);
  /// The [AirshipLocale] instance.
  static final locale = AirshipLocale(_module);
  /// The [AirshipAnalytics] instance.
  static final analytics = AirshipAnalytics(_module);
  /// The [AirshipActions] instance.
  static final actions = AirshipActions(_module);
  /// The [AirshipFeatureFlagsManager] instance.
  static final featureFlagManager = AirshipFeatureFlagsManager(_module);

  //
  /// Initializes Airship with the given config. Airship will store the config
  /// and automatically use it during the next app init. Any chances to config 
  /// could take an extra app init to apply.
  ///
  /// Returns true if Airship has been initialized, otherwise returns false.
  static Future<bool> takeOff(AirshipConfig config) async {
    return await _module.channel.invokeMethod('takeOff', config.toJson());
  }

  /// Gets deep link event stream.
  static Stream<DeepLinkEvent> get onDeepLink {
    return _module
        .getEventStream("com.airship.flutter/event/deep_link_received")
        .map((dynamic value) => DeepLinkEvent.fromJson(value));
  }
}