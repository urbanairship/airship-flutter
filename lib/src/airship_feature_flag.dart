import 'airship_module.dart';
import 'feature_flag.dart';

class AirshipFeatureFlag {

  final AirshipModule _module;

  AirshipFeatureFlag(AirshipFeatureFlag module) : this._module = module;

  Future<FeatureFlag> flag(String name) async {
    var featureFlag = await _module.channel.invokeMethod("featureFlag#flag", name);
    return FeatureFlag.fromJson(Map<String, dynamic>.from(featureFlag));
  }

}