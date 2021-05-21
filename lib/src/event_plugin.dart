import 'dart:ui';

import 'package:flutter/services.dart';
import 'callback_dispatcher.dart';

abstract class EventPlugin {

  static const MethodChannel _channel = const MethodChannel('com.airship.flutter/event_plugin');

  /*static Future<void> performAction(String payload) async {
    final callback = PluginUtilities.getCallbackHandle(callbackDispatcher);

    final args = <dynamic>[callback?.toRawHandle()];
    args.add(payload);
    await _channel.invokeMethod('performAction', args);
  }*/

}