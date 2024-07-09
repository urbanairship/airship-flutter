import 'airship_module.dart';

class AirshipInApp {

  final AirshipModule _module;

  AirshipInApp(AirshipModule module) : _module = module;

  /// Pauses or unpauses in-app automation.
  Future<void> setPaused(bool paused) async {
    return await _module.channel.invokeMethod('inApp#setPaused', paused);
  }

  /// Checks if in-app automation is paused or not.
  Future<bool> get isPaused async {
    return await _module.channel.invokeMethod('inApp#isPaused');
  }

  /// Sets the display interval for messages.
  Future<void> setDisplayInterval(int milliseconds) async {
    return _module.channel.invokeMethod('inApp#setDisplayInterval', milliseconds);
  }

  /// Gets the display interval for messages.
  Future<int> get displayInterval async {
    return await _module.channel.invokeMethod('inApp#getDisplayInterval');
  }
}