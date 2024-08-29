import 'dart:async';
import 'airship_module.dart';

class EmbeddedInfo {
  final String embeddedId;

  EmbeddedInfo(this.embeddedId);

  @override
  String toString() => "EmbeddedInfo(embeddedId=$embeddedId)";
}

class EmbeddedInfoUpdatedEvent {
  final List<EmbeddedInfo> embeddedInfos;

  const EmbeddedInfoUpdatedEvent(this.embeddedInfos);

  static EmbeddedInfoUpdatedEvent fromJson(dynamic json) {
    List<dynamic> pendingList = json['pending'] as List? ?? [];

    List<EmbeddedInfo> embeddedInfos =
        pendingList.map((item) => EmbeddedInfo(item['embeddedId'])).toList();

    return EmbeddedInfoUpdatedEvent(embeddedInfos);
  }

  @override
  String toString() => "EmbeddedInfoUpdatedEvent(embeddedInfos=$embeddedInfos)";
}

class AirshipAutomation {
  final AirshipModule _module;
  final Map<String, StreamController<bool>> _isEmbeddedAvailableControllers =
      {};
  List<EmbeddedInfo> _embeddedInfos = [];
  late StreamSubscription<EmbeddedInfoUpdatedEvent> _subscription;

  AirshipAutomation(this._module) {
    _subscription = onEmbeddedInfoUpdated.listen(_updateEmbeddedIds);
  }

  Stream<bool> isEmbeddedAvailableStream({required String embeddedId}) =>
      (_isEmbeddedAvailableControllers[embeddedId] ??=
              StreamController<bool>.broadcast()
                ..add(isEmbeddedAvailable(embeddedId: embeddedId)))
          .stream;

  bool isEmbeddedAvailable({required String embeddedId}) =>
      _embeddedInfos.any((info) => info.embeddedId == embeddedId);

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
