
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void callbackDispatcher() {
  const MethodChannel _backgroundChannel = MethodChannel('com.airship.flutter/event_plugin_background');

  WidgetsFlutterBinding.ensureInitialized();

  _backgroundChannel.setMethodCallHandler((MethodCall call) async {
    final args = call.arguments;

    final Function callback = PluginUtilities.getCallbackFromHandle(CallbackHandle.fromRawHandle(args[0]))!;

    final payload = args[1].cast<String>();

    callback(payload);
  });

  _backgroundChannel.invokeMethod('EventService.performed');
}