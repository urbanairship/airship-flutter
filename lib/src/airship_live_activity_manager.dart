import 'airship_module.dart';
import 'live_activity.dart';

/// Live Activity manager.
class AirshipLiveActivityManager {
  final AirshipModule _module;

  AirshipLiveActivityManager(AirshipModule module) : _module = module;

  /// Starts a Live Activity.
  /// @param request The request options.
  /// @returns A Future with the result.
  Future<LiveActivity> start(LiveActivityStartRequest request) async {
    var response = await _module.channel
        .invokeMethod('liveActivity#start', request.toJson());
    return LiveActivity.fromJson(response);
  }

  /// Lists any Live Activities for the request.
  /// @param request The request options.
  /// @returns A Future with the result.
  Future<List<LiveActivity>> list(LiveActivityListRequest request) async {
    var response = await _module.channel
        .invokeMethod('liveActivity#list', request.toJson());
    return (response as List).map((e) => LiveActivity.fromJson(e)).toList();
  }

  /// Lists all Live Activities.
  /// @returns A Future with the result.
  Future<List<LiveActivity>> listAll() async {
    var response = await _module.channel.invokeMethod('liveActivity#listAll');
    return (response as List).map((e) => LiveActivity.fromJson(e)).toList();
  }

  /// Updates a Live Activity.
  /// @param request The request options.
  /// @returns A Future with the result.
  Future<void> update(LiveActivityUpdateRequest request) async {
    await _module.channel.invokeMethod('liveActivity#update', request.toJson());
  }

  /// End a Live Activity.
  /// @param request The request options.
  /// @returns A Future with the result.
  Future<void> end(LiveActivityStopRequest request) async {
    await _module.channel.invokeMethod('liveActivity#stop', request.toJson());
  }
}
