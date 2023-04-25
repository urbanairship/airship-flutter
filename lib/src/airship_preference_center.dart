import 'airship_module.dart';
import 'dart:convert';
import 'preference_center_config.dart';

class AirshipPreferenceCenter {

  final AirshipModule _module;

  AirshipPreferenceCenter(AirshipModule module) : this._module = module;
  
  /// Returns the configuration of the Preference Center with the given [preferenceCenterID].
  Future<PreferenceCenterConfig?> getConfig(String preferenceCenterID) async {
    var config = await _module.channel.invokeMethod(
        'preferenceCenter#getConfig', preferenceCenterID);
    return PreferenceCenterConfig.fromJson(jsonDecode(config));
  }

  /// Enables or disables auto launching the Preference Center with the given [preferenceCenterID].
  /// If auto launch is enabled, Airship will show an OOTB UI for the given preference center ID. If
  /// disabled, a display preference center event will be emitted.
  Future<void> setAutoLaunchPreferenceCenter(String preferenceCenterID, bool autoLaunch) async {
    return await _module.channel.invokeMethod('preferenceCenter#setAutoLaunch', [preferenceCenterID, autoLaunch]);
  }

  /// Opens the Preference Center with the given [preferenceCenterID].
  Future<void> openPreferenceCenter(String preferenceCenterID) async {
    return await _module.channel.invokeMethod(
        'preferenceCenter#display', preferenceCenterID);
  }

  /// Gets show preference center event stream.
  Stream<String?> get onShowPreferenceCenter {
    return _module.getEventStream("SHOW_PREFERENCE_CENTER")!
        .map((dynamic value) => jsonDecode(value) as String?);
  }

}