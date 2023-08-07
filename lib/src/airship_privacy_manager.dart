import 'airship_module.dart';
import 'feature.dart';

class AirshipPrivacyManager {

  final AirshipModule _module;

  AirshipPrivacyManager(AirshipModule module) : this._module = module;

  /// Enables one or many [features].
  Future<void> enableFeatures(List<Feature> features) async {
    List<String> featuresString = <String>[];
    features.forEach((element) {
      featuresString.add(element.stringValue);
    });
    return await _module.channel.invokeMethod('privacyManager#enableFeatures', featuresString);
  }

  /// Disables one or many [features].
  Future<void> disableFeatures(List<Feature> features) async {
    List<String> featuresString = <String>[];
    features.forEach((element) {
      featuresString.add(element.stringValue);
    });
    return await _module.channel.invokeMethod('privacyManager#disableFeatures', featuresString);
  }

  /// Sets the SDK [features] that will be enabled. The rest of the features will be disabled.
  ///
  /// If all features are disabled the SDK will not make any network requests or collect data.
  /// Note that all features are enabled by default.
  Future<void> setEnabledFeatures(List<Feature> features) async {
    List<String> featuresString = <String>[];
    features.forEach((element) {
        featuresString.add(element.stringValue);
    });
    return await _module.channel.invokeMethod('privacyManager#setEnabledFeatures', featuresString);
  }

  /// Returns a [List] with the enabled features.
  Future<List<Feature>> get enabledFeatures async {
    var payload = await _module.channel.invokeMethod('privacyManager#getEnabledFeatures');
    List<Feature> parsedFeatures = <Feature>[];
    List<String>.from(payload).forEach((String feature) =>
        parsedFeatures.add(feature.feature));
    return parsedFeatures;
  }

  /// Checks if a given list of [features] are enabled or not.
  Future<bool> isFeaturesEnabled(List<Feature> features) async {
    List<String> featuresString = <String>[];
    features.forEach((element) {
      featuresString.add(element.stringValue);
    });
    return await _module.channel.invokeMethod('privacyManager#isFeaturesEnabled', featuresString);
  }

}