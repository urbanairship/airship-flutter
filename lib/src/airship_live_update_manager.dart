import 'airship_module.dart';
import 'live_update.dart';

/// Live Update manager.
class AirshipLiveUpdateManager {
  final AirshipModule _module;

  AirshipLiveUpdateManager(this._module);

  /// Creates a Live Update.
  /// @param request The request options.
  /// @returns A Future with the result.
  Future<void> start(LiveUpdateStartRequest request) async {
    await _module.channel.invokeMethod('liveUpdate#start', request.toJson());
  }

  /// Updates a Live Update.
  /// @param request The request options.
  /// @returns A Future with the result.
  Future<void> update(LiveUpdateUpdateRequest request) async {
    await _module.channel.invokeMethod('liveUpdate#update', request.toJson());
  }

  /// Lists any Live Updates for the request.
  /// @param request The request options.
  /// @returns A Future with the result.
  Future<List<LiveUpdate>> list(LiveUpdateListRequest request) async {
    var response =
        await _module.channel.invokeMethod('liveUpdate#list', request.toJson());
    return (response as List<Object?>)
        .map((e) => LiveUpdate.fromJson(e as Map<String, Object?>))
        .toList();
  }

  /// Lists all Live Updates.
  /// @returns A Future with the result.
  Future<List<LiveUpdate>> listAll() async {
    try {
      final result = await _module.channel.invokeMethod('liveUpdate#listAll');
      if (result is List) {
        return result.map((item) => LiveUpdate.fromJson(item)).toList();
      }
      throw FormatException(
          'Invalid result format: expected a List, got ${result.runtimeType}');
    } catch (e) {
      print('Error listing all live updates: $e');
      rethrow;
    }
  }

  /// End a Live Update.
  /// @param request The request options.
  /// @returns A Future with the result.
  Future<void> end(LiveUpdateEndRequest request) async {
    await _module.channel.invokeMethod('liveUpdate#end', request.toJson());
  }
}
