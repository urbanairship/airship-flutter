import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' hide Notification;
import 'package:airship_flutter/airship_flutter.dart';

import 'dart:developer';

import 'airship_module.dart';
import 'events.dart';

/// The Main Airship API.
class Airship {

  static final _module = AirshipModule();
  static final channel = AirshipChannel(_module);
  static final push = AirshipPush(_module);
  static final contact = AirshipContact(_module);
  static final inApp = AirshipInApp(_module);
  static final messageCenter = AirshipMessageCenter(_module);
  static final privacyManager = AirshipPrivacyManager(_module);
  static final preferenceCenter = AirshipPreferenceCenter(_module);
  static final locale = AirshipLocale(_module);
  static final analytics = AirshipAnalytics(_module);
  static final actions = AirshipActions(_module);
  static bool _isBackgroundHandlerSet = false;


  //
  /// Initializes Airship with an [appKey] and [appSecret].
  ///
  /// Returns true if Airship has been initialized, otherwise returns false.
  static Future<bool> takeOff(AirshipConfig config) async {
    return await _module.channel.invokeMethod('takeOff', config.toJson());
  }

  /// Sets a background message handler.
  static Future<void> setBackgroundMessageHandler(
      BackgroundMessageHandler handler) async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    if (_isBackgroundHandlerSet) {
      print("Airship background message handler already set!");
      return;
    }
    _isBackgroundHandlerSet = true;

    final isolateCallback =
    PluginUtilities.getCallbackHandle(_backgroundMessageIsolateCallback)!;
    final messageCallback = PluginUtilities.getCallbackHandle(handler)!;
    await _module.channel.invokeMapMethod("startBackgroundIsolate", {
      "isolateCallback": isolateCallback.toRawHandle(),
      "messageCallback": messageCallback.toRawHandle()
    });
  }

  /// Gets deep link event stream.
  static Stream<DeepLinkEvent> get onDeepLink {
    return _module
        .getEventStream("com.airship.flutter/event/deep_link_received")
        .map((dynamic value) => Map<String, dynamic>.from(value))
        .map((Map<String, dynamic> value) => DeepLinkEvent.fromJson(value));
  }
}

@pragma('vm:entry-point')
void _backgroundMessageIsolateCallback() {
  log("Flutter start backgroundMessageIsolateCallback");
  WidgetsFlutterBinding.ensureInitialized();

  Airship._module.backgroundChannel.setMethodCallHandler((call) async {
    if (call.method == "onBackgroundMessage") {
      final args = call.arguments;
      final handle = CallbackHandle.fromRawHandle(args["messageCallback"]);
      final callback = PluginUtilities.getCallbackFromHandle(handle)
      as BackgroundMessageHandler;
      try {
        final payload = Map<String, dynamic>.from((args["event"]));
        var notification;
        if (args["notification"] != null) {
          notification =
              Notification.fromJson(jsonDecode(args["notification"]));
        }
        await callback(payload, notification);
      } catch (e) {
        print("Airship: Failed to handle background message!");
        print(e);
      }
    } else {
      throw UnimplementedError("${call.method} is not implemented!");
    }
  });

  // Tell the native side to start the background isolate.
  Airship._module.backgroundChannel.invokeMethod<void>(
      "backgroundIsolateStarted");
}


typedef BackgroundMessageHandler = Future<void> Function(
    Map<String, dynamic> payload, Notification? notification);
