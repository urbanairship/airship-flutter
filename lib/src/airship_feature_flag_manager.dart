import 'package:flutter/services.dart';
import 'airship_module.dart';
import 'dart:convert';

/// Feature flag manager
class AirshipFeatureFlagManager {
  final AirshipModule _module;

  AirshipFeatureFlagManager(AirshipModule module) : _module = module;

  /// Gets and evaluates a feature flag with the given [name].
  ///
  /// [useResultCache] determines if the result cache should be used when
  /// evaluating the flag. Defaults to `true`.
  ///
  /// Throws a [PlatformException] if the flag fails to resolve, e.g. if the
  /// flags have not yet been downloaded or Airship is not ready.
  Future<FeatureFlag> flag(String name, {bool useResultCache = true}) async {
    var featureFlag = await _module.channel.invokeMethod(
      "featureFlagManager#flag",
      {
        "flagName": name,
        "useResultCache": useResultCache,
      },
    );

    if (featureFlag == null) {
      throw PlatformException(
        code: "AIRSHIP_ERROR",
        message: "Failed to fetch feature flag: $name",
        details: "Method: featureFlagManager#flag",
      );
    }

    return FeatureFlag._fromJson(featureFlag);
  }

  /// Tracks interaction with feature flag
  Future<void> trackInteraction(FeatureFlag flag) async {
    return await _module.channel
        .invokeMethod("featureFlagManager#trackInteraction", flag.toJSON());
  }

  /// Gets a flag from the result cache. Returns null if the flag is not
  /// cached or the cached value has expired.
  Future<FeatureFlag?> getFlagFromResultCache(String flagName) async {
    var featureFlag = await _module.channel.invokeMethod(
      "featureFlagManager#resultCacheGetFlag",
      flagName,
    );
    return featureFlag != null ? FeatureFlag._fromJson(featureFlag) : null;
  }

  /// Sets a flag in the result cache with the given [ttl].
  Future<void> setFlagInResultCache(FeatureFlag flag, Duration ttl) async {
    await _module.channel.invokeMethod(
      "featureFlagManager#resultCacheSetFlag",
      {
        "flag": flag.toJSON(),
        "ttl": ttl.inMilliseconds,
      },
    );
  }

  /// Removes a flag from the result cache.
  Future<void> removeFlagFromResultCache(String flagName) async {
    await _module.channel.invokeMethod(
      "featureFlagManager#resultCacheRemoveFlag",
      flagName,
    );
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
  final Map<String, Object?>? variables;

  const FeatureFlag._internal(
      this.original, this.isEligible, this.exists, this.variables);

  static FeatureFlag _fromJson(dynamic json) {
    var isEligible = json[IS_ELIGIBLE];
    var exists = json[EXISTS];

    Map<String, Object?>? variables;
    if (json[VARIABLES] != null) {
      variables = Map<String, Object?>.from(json[VARIABLES]);
    }

    var original = json[ORIGINAL];

    return FeatureFlag._internal(original, isEligible, exists, variables);
  }

  String toJSON() {
    final Map<String, Object?> data = {
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