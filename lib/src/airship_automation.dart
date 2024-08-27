import 'dart:async';
import 'airship_module.dart';
import 'airship_events.dart';

class AirshipAutomation {
  final AirshipModule _module;
  final Map<String, StreamController<bool>> _isReadyControllers = {};
  List<String> _embeddedIds = [];
  late StreamSubscription<EmbeddedInfoUpdatedEvent> _subscription;

  AirshipAutomation(this._module) {
    _subscription = onEmbeddedInfoUpdated.listen(_updateEmbeddedIds);
  }

  Stream<bool> isReadyStream({required String embeddedId}) =>
      (_isReadyControllers[embeddedId] ??= StreamController<bool>.broadcast()
            ..add(isReady(embeddedId: embeddedId)))
          .stream;

  bool isReady({required String embeddedId}) =>
      _embeddedIds.contains(embeddedId);

  Stream<EmbeddedInfoUpdatedEvent> get onEmbeddedInfoUpdated => _module
      .getEventStream("com.airship.flutter/event/embedded_info_updated")
      .map(EmbeddedInfoUpdatedEvent.fromJson);

  void _updateEmbeddedIds(EmbeddedInfoUpdatedEvent event) {
    _embeddedIds = event.embeddedIds;
    _isReadyControllers
        .forEach((id, controller) => controller.add(_embeddedIds.contains(id)));
  }

  void dispose() {
    _subscription.cancel();
    for (var controller in _isReadyControllers.values) {
      controller.close();
    }
  }
}
