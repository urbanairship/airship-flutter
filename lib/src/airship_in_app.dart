// class AirshipInApp {
//
//   const MethodChannel _channel;
//
//   const AirshipInApp._internal(this._channel)
//
//
//   /// Pauses or unpauses in-app automation.
//   static Future<void> setInAppAutomationPaused(bool paused) async {
//     return await _channel.invokeMethod('setInAppAutomationPaused', paused);
//   }
//
//   /// Checks if in-app automation is paused or not.
//   static Future<void> get getInAppAutomationPaused async {
//     return await _channel.invokeMethod('getInAppAutomationPaused');
//   }
//
// }