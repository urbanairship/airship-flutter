import 'airship_module.dart';
import 'dart:ffi';

class AirshipInApp {

  final AirshipModule _module;

  AirshipInApp(AirshipModule module) : this._module = module;

  /// Pauses or unpauses in-app automation.
  Future<void> setInAppAutomationPaused(bool paused) async {
    return await _module.channel.invokeMethod('inApp#setPaused', paused);
  }

  /// Checks if in-app automation is paused or not.
  Future<bool> get getInAppAutomationPaused async {
    return await _module.channel.invokeMethod('inApp#isPaused');
  }

  /// Sets the display interval for messages.
  Future<void> setDisplayInterval(int milliseconds) async {
    return await _module.channel.invokeMethod('inApp#setDisplayInterval', milliseconds);
  }

  /// Gets the display interval for messages.
  Future<int> get getDisplayInterval async {
    return await _module.channel.invokeMethod('inApp#getDisplayInterval');
  }



}