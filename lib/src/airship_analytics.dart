import 'airship_module.dart';
import 'custom_event.dart';

class AirshipAnalytics {

  final AirshipModule _module;

  AirshipAnalytics(AirshipModule module) : this._module = module;

  /// Initiates [screen] tracking for a specific app screen. Must be called once per tracked screen.
  Future<void> trackScreen(String screen) async {
    return await _module.channel.invokeMethod('analytics#trackScreen', screen);
  }

  /// Associates an identifier.
  Future<void> associateIdentifier(String key, String? identifier) async {
    var args = [key, identifier];
    return await _module.channel.invokeMethod('analytics#associateIdentifier', args);
  }

  /// Adds a custom [event].
  Future<void> addEvent(CustomEvent event) async {
    return await _module.channel.invokeMethod('analytics#addEvent', event.toMap());
  }

}