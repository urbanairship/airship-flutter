import 'airship_module.dart';
import 'feature_flag.dart';

class AirshipFeatureFlag {

  final AirshipModule _module;

  AirshipFeatureFlag(AirshipModule module) : this._module = module;

  /// Gets and evaluates a feature flag with the given [name].
  Future<FeatureFlag?> flag(String name) async {
    var featureFlag = await _module.channel.invokeMethod("featureFlag#flag", name);
    return FeatureFlag.fromJson(Map<String, dynamic>.from(featureFlag));
  }

}