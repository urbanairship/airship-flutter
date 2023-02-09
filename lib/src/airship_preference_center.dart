// import 'preference_center_config.dart';
//
// class AirshipPreferenceCenter {
//
//   const MethodChannel _channel;
//
//   const AirshipPreferenceCenter._internal(this._channel)
//
//   /// Returns the configuration of the Preference Center with the given [preferenceCenterID].
//   Future<PreferenceCenterConfig?> getConfig(String preferenceCenterID) async {
//     var config = await _channel.invokeMethod(
//         'preferenceCenter#getConfig', preferenceCenterID);
//     return PreferenceCenterConfig.fromJson(jsonDecode(config));
//   }
//
//   /// Enables or disables auto launching the Preference Center with the given [preferenceCenterID].
//   /// If auto launch is enabled, Airship will show an OOTB UI for the given preference center ID. If
//   /// disabled, a display preference center event will be emitted.
//   Future<void> setAutoLaunchPreferenceCenter(String preferenceCenterID, bool autoLaunch) async {
//     return await _channel.invokeMethod('setAutoLaunch', [preferenceCenterID, autoLaunch]);
//   }
//
//   /// Opens the Preference Center with the given [preferenceCenterID].
//   static Future<void> openPreferenceCenter(String preferenceCenterID) async {
//     return await _channel.invokeMethod(
//         'openPreferenceCenter', preferenceCenterID);
//   }
//
//
//
//   /// Gets show preference center event stream.
//   static Stream<String?> get onShowPreferenceCenter {
//     return _getEventStream("SHOW_PREFERENCE_CENTER")!
//         .map((dynamic value) => jsonDecode(value) as String?);
//   }
//
// }