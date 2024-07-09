import 'airship_module.dart';
import 'dart:convert';

/// Feature flag manager
class AirshipFeatureFlagManager {

  final AirshipModule _module;

  AirshipFeatureFlagManager(AirshipModule module) : this._module = module;

  /// Gets and evaluates a feature flag with the given [name].
  Future<FeatureFlag> flag(String name) async {
    var featureFlag = await _module.channel.invokeMethod("featureFlagManager#flag", name);
    return FeatureFlag._fromJson(featureFlag);
  }

    /// Tracks interaction with feature flag
  Future<void> trackInteraction(FeatureFlag flag) async {
    return await _module.channel.invokeMethod("featureFlagManager#trackInteraction", flag.toJSON());
  }
}


/// Airship feature flag object.
class FeatureFlag {
  static const IS_ELIGIBLE = "isEligible";
  static const EXISTS = "exists";
  static const VARIABLES = "variables";
  static const ORIGINAL = "_internal";

  /// The original flag json from which the original FeatureFlag can be constructed
  final dynamic original;

  /// Indicates whether the device is eligible or not for the flag.
  final bool isEligible;

  /// Indicates whether the flag exists in the current flag listing or not.
  final bool exists;

  /// Optional variables associated with the flag.
  final Map<String, dynamic>? variables;

  const FeatureFlag._internal(this.original, this.isEligible, this.exists, this.variables);

  static FeatureFlag _fromJson(dynamic json) {
    var isEligible = json[IS_ELIGIBLE];
    var exists = json[EXISTS];

    Map<String, dynamic>? variables;
    if (json[VARIABLES] != null) {
      variables = Map<String, dynamic>.from(json[VARIABLES]);
    }

    var original = json[ORIGINAL];

    return FeatureFlag._internal(original, isEligible, exists, variables);
  }

  String toJSON() {
    final Map<String, dynamic> data = {
      IS_ELIGIBLE: isEligible,
      EXISTS: exists,
      VARIABLES: variables,
      ORIGINAL: original
    };
    return jsonEncode(data);
  }

  @override
  String toString() {
    return "FeatureFlag($ORIGINAL=$original, $IS_ELIGIBLE=$isEligible, $EXISTS=$exists, $VARIABLES=$variables)";
  }
}