import 'airship_module.dart';

/// Feature flag manager
class AirshipFeatureFlagManager {

  final AirshipModule _module;

  AirshipFeatureFlagManager(AirshipModule module) : this._module = module;

  /// Gets and evaluates a feature flag with the given [name].
  Future<FeatureFlag> flag(String name) async {
    var featureFlag = await _module.channel.invokeMethod("featureFlagManager#flag", name);
    return FeatureFlag._fromJson(featureFlag);
  }
}


/// Airship feature flag object.
class FeatureFlag {

  /// Indicates whether the device is eligible or not for the flag.
  final bool isEligible;

  /// Indicates whether the flag exists in the current flag listing or not.
  final bool exists;

  /// Optional variables associated with the flag.
  final Map<String, dynamic>? variables;

  const FeatureFlag._internal(this.isEligible, this.exists, this.variables);

  static FeatureFlag _fromJson(dynamic json) {
    var isEligible = json["isEligible"];
    var exists = json["exists"];

    var variables;
    if (json["variables"] != null) {
      variables = Map<String, dynamic>.from(json["variables"]);
    }

    return FeatureFlag._internal(isEligible, exists, variables);
  }

  @override
  String toString() {
    return "FeatureFlag(isEligible=$isEligible, exists=$exists, variables=$variables)";
  }
}