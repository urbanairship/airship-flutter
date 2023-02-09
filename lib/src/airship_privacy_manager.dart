// enum Feature {
//   push,
//   analytics,
//   inAppAutomation,
//   tagsAndAttributes,
//   chat,
//   location,
//   messageCenter
// }
//
// class AirshipPrivacyManager {
//   const MethodChannel _channel;
//
//   const AirshipPrivacyManager._internal(this._channel)
//
//   /// Enables one or many [features].
//   Future<void> enableFeatures(List<String> features) async {
//     return await _channel.invokeMethod('enableFeatures', features);
//   }
//
//   /// Disables one or many [features].
//   Future<void> disableFeatures(List<String> features) async {
//     return await _channel.invokeMethod('disableFeatures', features);
//   }
//
//   /// Sets the SDK [features] that will be enabled. The rest of the features will be disabled.
//   ///
//   /// If all features are disabled the SDK will not make any network requests or collect data.
//   /// Note that all features are enabled by default.
//   Future<void> setEnabledFeatures(List<String> features) async {
//     return await _channel.invokeMethod('setEnabledFeatures', features);
//   }
//
//   /// Returns a [List] with the enabled features.
//   Future<List<String>> getEnabledFeatures() async {
//     return await _channel.invokeMethod('getEnabledFeatures');
//   }
//
//   /// Checks if a given [feature] is enabled or not.
//   Future<bool> isFeaturesEnabled(String feature) async {
//     return await _channel.invokeMethod('isFeatureEnabled', feature);
//   }
//
// }