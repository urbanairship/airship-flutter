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
        _resendLastEmbeddedUpdate();
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

  Future<void> _resendLastEmbeddedUpdate() async {
    try {
      await _module.channel.invokeMethod("inApp#resendEmbeddedEvent");
    } catch (e) {
      print("Error resending embedded update: $e");
    }
  }

  void dispose() {
    _eventSubscription?.cancel();
    _embeddedInfoUpdatedController.close();
  }
}
