import 'package:flutter/services.dart';

class AirshipModule {

  static final AirshipModule singleton = AirshipModule._internal();

  factory AirshipModule() {
    return singleton;
  }

  AirshipModule._internal();

  final Map<String, EventChannel> _eventChannels = new Map();
  final Map<String, Stream<dynamic>> _eventStreams = new Map();

  final MethodChannel channel = const MethodChannel('com.airship.flutter/airship');
  final MethodChannel backgroundChannel = const MethodChannel('com.airship.flutter/airship_background');

  Stream<dynamic> getEventStream(String name) {
    if (_eventChannels[name] == null) {
      _eventChannels[name] = EventChannel(name);
    }

    if (_eventStreams[name] == null) {
      _eventStreams[name] = _eventChannels[name]!.receiveBroadcastStream();
    }

    return _eventStreams[name]!;
  }
}
