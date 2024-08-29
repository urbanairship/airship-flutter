import 'package:airship_flutter/airship_flutter.dart';

import 'airship_module.dart';
import 'dart:async';

class AirshipInApp {
  final AirshipModule _module;

  AirshipInApp(this._module) {
    _subscription = onEmbeddedInfoUpdated.listen(_updateEmbeddedIds);
  }

  final Map<String, StreamController<bool>> _isEmbeddedAvailableControllers =
      {};
  List<EmbeddedInfo> _embeddedInfos = [];
  late StreamSubscription<EmbeddedInfoUpdatedEvent> _subscription;

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
    return _module.channel
        .invokeMethod('inApp#setDisplayInterval', milliseconds);
  }

  /// Gets the display interval for messages.
  Future<int> get displayInterval async {
    return await _module.channel.invokeMethod('inApp#getDisplayInterval');
  }

  bool isEmbeddedAvailable({required String embeddedId}) =>
      _embeddedInfos.any((info) => info.embeddedId == embeddedId);

  Stream<bool> isEmbeddedAvailableStream({required String embeddedId}) =>
      (_isEmbeddedAvailableControllers[embeddedId] ??=
              StreamController<bool>.broadcast()
                ..add(isEmbeddedAvailable(embeddedId: embeddedId)))
          .stream;

  List<EmbeddedInfo> getEmbeddedInfos() => _embeddedInfos;

  Stream<EmbeddedInfoUpdatedEvent> get onEmbeddedInfoUpdated => _module
      .getEventStream("com.airship.flutter/event/embedded_info_updated")
      .map(EmbeddedInfoUpdatedEvent.fromJson);

  void _updateEmbeddedIds(EmbeddedInfoUpdatedEvent event) {
    _embeddedInfos = event.embeddedInfos;
    _isEmbeddedAvailableControllers.forEach((id, controller) =>
        controller.add(isEmbeddedAvailable(embeddedId: id)));
  }

  void dispose() {
    _subscription.cancel();
    for (var controller in _isEmbeddedAvailableControllers.values) {
      controller.close();
    }
  }
}
