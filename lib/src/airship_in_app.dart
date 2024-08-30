import 'package:airship_flutter/airship_flutter.dart';
import 'airship_module.dart';
import 'dart:async';

class AirshipInApp {
  final AirshipModule _module;
  final Map<String, StreamController<bool>> _isEmbeddedAvailableControllers =
      {};
  List<EmbeddedInfo> _embeddedInfos = [];
  late final StreamController<EmbeddedInfoUpdatedEvent>
      _embeddedInfoUpdatedController;
  late final StreamSubscription<EmbeddedInfoUpdatedEvent> _subscription;

  List<EmbeddedInfo> getEmbeddedInfos() => _embeddedInfos;

  AirshipInApp(this._module) {
    _embeddedInfoUpdatedController =
        StreamController<EmbeddedInfoUpdatedEvent>.broadcast();
    _setupEventStream();
    _subscription = onEmbeddedInfoUpdated.listen(_updateEmbeddedIds);
  }

  /// A flag to determine if an embedded id is available that is not live updated
  bool isEmbeddedAvailable({required String embeddedId}) =>
      _embeddedInfos.any((info) => info.embeddedId == embeddedId);

  /// A live updated stream to determine if an embedded id is available
  Stream<bool> isEmbeddedAvailableStream({required String embeddedId}) =>
      (_isEmbeddedAvailableControllers[embeddedId] ??=
              StreamController<bool>.broadcast()
                ..add(isEmbeddedAvailable(embeddedId: embeddedId)))
          .stream;

  Stream<EmbeddedInfoUpdatedEvent> get onEmbeddedInfoUpdated =>
      _embeddedInfoUpdatedController.stream;

  void _setupEventStream() {
    _module
        .getEventStream("com.airship.flutter/event/pending_embedded_updated")
        .listen((event) {
      try {
        _embeddedInfoUpdatedController
            .add(EmbeddedInfoUpdatedEvent.fromJson(event));
      } catch (e) {
        print("Error parsing EmbeddedInfoUpdatedEvent: $e");
      }
    });
  }

  void _updateEmbeddedIds(EmbeddedInfoUpdatedEvent event) {
    /// Update the embedded infos list
    _embeddedInfos = event.embeddedInfos;

    /// Update stream controllers for each embedded id so everything remains synced
    _isEmbeddedAvailableControllers.forEach((id, controller) =>
        controller.add(isEmbeddedAvailable(embeddedId: id)));
  }

  void dispose() {
    _subscription.cancel();

    /// Remove and close all stream controllers for each embedded id
    _isEmbeddedAvailableControllers.values
        .forEach((controller) => controller.close());
    _embeddedInfoUpdatedController.close();
  }
}
