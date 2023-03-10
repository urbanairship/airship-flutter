import 'airship_module.dart';

class AirshipActions {

  final AirshipModule _module;

  AirshipActions(AirshipModule module) : this._module = module;

  Future<String?> run(String actionName, dynamic? actionValue) async {
    return await _module.channel.invokeMethod('actions#run', [actionName, actionValue]);
  }
}