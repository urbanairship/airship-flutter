import 'package:airship_flutter/airship_flutter.dart';
import 'airship_module.dart';
import 'dart:async';

class AirshipInApp {
  final AirshipModule _module;
  List<EmbeddedInfo> _embeddedInfos = [];
  late final StreamController<List<EmbeddedInfo>>
      _embeddedInfoUpdatedController;
  StreamSubscription? _eventSubscription;
  bool _isFirstStream = true;

  AirshipInApp(this._module) {
    _setupEventStream();
    _setupController();
  }

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

  List<EmbeddedInfo> getEmbeddedInfos() => _embeddedInfos;

  bool isEmbeddedAvailable({required String embeddedId}) =>
      _embeddedInfos.any((info) => info.embeddedId == embeddedId);

  Stream<bool> isEmbeddedAvailableStream({required String embeddedId}) =>
      onEmbeddedInfoUpdated.map((embeddedInfos) =>
          embeddedInfos.any((info) => info.embeddedId == embeddedId));

  Stream<List<EmbeddedInfo>> get onEmbeddedInfoUpdated =>
      _embeddedInfoUpdatedController.stream;

  void _setupController() {
    _embeddedInfoUpdatedController =
        StreamController<List<EmbeddedInfo>>.broadcast(onListen: () {
      if (_isFirstStream) {
        _isFirstStream = false;
        _resendLastEmbeddedEvent();
      }
    });
  }

  void _setupEventStream() {
    _eventSubscription = _module
        .getEventStream("com.airship.flutter/event/pending_embedded_updated")
        .listen((event) {
      try {
        final updatedEvent = EmbeddedInfoUpdatedEvent.fromJson(event);
        _embeddedInfos = updatedEvent.embeddedInfos;
        _embeddedInfoUpdatedController.add(_embeddedInfos);
      } catch (e) {
        print("Error parsing EmbeddedInfoUpdatedEvent: $e");
      }
    });
  }

  Future<void> _resendLastEmbeddedEvent() async {
    try {
      await _module.channel.invokeMethod("inApp#resendLastEmbeddedEvent");
    } catch (e) {
      print("Error resending embedded update: $e");
    }
  }

  void dispose() {
    _eventSubscription?.cancel();
    _embeddedInfoUpdatedController.close();
  }
}
