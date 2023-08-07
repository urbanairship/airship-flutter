import 'airship_module.dart';
import 'feature.dart';
import 'airship_utils.dart';

class AirshipPrivacyManager {

  final AirshipModule _module;

  AirshipPrivacyManager(AirshipModule module) : this._module = module;

  /// Enables one or many [features].
  Future<void> enableFeatures(List<Feature> features) async {
    List<String> featuresStrings = AirshipUtils.toFeatureStringList(features);
    return await _module.channel.invokeMethod('privacyManager#enableFeatures', featuresStrings);
  }

  /// Disables one or many [features].
  Future<void> disableFeatures(List<Feature> features) async {
    List<String> featuresStrings = AirshipUtils.toFeatureStringList(features);
    return await _module.channel.invokeMethod('privacyManager#disableFeatures', featuresStrings);
  }

  /// Sets the SDK [features] that will be enabled. The rest of the features will be disabled.
  ///
  /// If all features are disabled the SDK will not make any network requests or collect data.
  /// Note that all features are enabled by default.
  Future<void> setEnabledFeatures(List<Feature> features) async {
    List<String> featuresStrings = AirshipUtils.toFeatureStringList(features);
    return await _module.channel.invokeMethod('privacyManager#setEnabledFeatures', featuresStrings);
  }

  /// Returns a [List] with the enabled features.
  Future<List<Feature>> get enabledFeatures async {
    var response = await _module.channel.invokeMethod('privacyManager#getEnabledFeatures');
    return AirshipUtils.parseFeatures(List<String>.from(response));
  }

  /// Checks if a given list of [features] are enabled or not.
  Future<bool> isFeaturesEnabled(List<Feature> features) async {
    List<String> featuresStrings = AirshipUtils.toFeatureStringList(features);
    return await _module.channel.invokeMethod('privacyManager#isFeaturesEnabled', featuresStrings);
  }
}
