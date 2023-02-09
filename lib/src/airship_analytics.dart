// class AirshipAnalytics {
//
//   const Mo _channel;
//
//   const AirshipAnalytics._internal(this._channel)
//
//
//   /// Initiates [screen] tracking for a specific app screen. Must be called once per tracked screen.
//   static Future<void> trackScreen(String screen) async {
//     return await _channel.invokeMethod('trackScreen', screen);
//   }
//
//   /// Adds a custom [event].
//   static Future<void> addEvent(CustomEvent event) async {
//     return await _channel.invokeMethod('addEvent', event.toMap());
//   }
//
// }