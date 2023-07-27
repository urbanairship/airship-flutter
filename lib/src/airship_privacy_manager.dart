import 'airship_module.dart';
import 'feature.dart';

class AirshipPrivacyManager {

  final AirshipModule _module;

  AirshipPrivacyManager(AirshipModule module) : this._module = module;

  /// Enables one or many [features].
  Future<void> enableFeatures(List<String> features) async {
    return await _module.channel.invokeMethod('privacyManager#enableFeatures', features);
  }

  /// Disables one or many [features].
  Future<void> disableFeatures(List<String> features) async {
    return await _module.channel.invokeMethod('privacyManager#disableFeatures', features);
  }

  /// Sets the SDK [features] that will be enabled. The rest of the features will be disabled.
  ///
  /// If all features are disabled the SDK will not make any network requests or collect data.
  /// Note that all features are enabled by default.
  Future<void> setEnabledFeatures(List<String> features) async {
    return await _module.channel.invokeMethod('privacyManager#setEnabledFeatures', features);
  }

  /// Returns a [List] with the enabled features.
  Future<List<String>> get enabledFeatures async {
    List features = await _module.channel.invokeMethod('privacyManager#getEnabledFeatures');
    return features.cast<String>();
  }

  /// Checks if a given list of [features] are enabled or not.
  Future<bool> isFeaturesEnabled(List<String> features) async {
    return await _module.channel.invokeMethod('privacyManager#isFeaturesEnabled', features);
  }

}