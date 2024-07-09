import 'dart:async';
import 'package:flutter/services.dart';

/// Editor for tags.
class TagEditor {
  static const TAG_OPERATION_ADD = "add";
  static const TAG_OPERATION_REMOVE = "remove";

  static const TAG_OPERATION_TAGS = "tags";
  static const TAG_OPERATION_TYPE = "operationType";

  final MethodChannel _channel;

  /// The method name.
  final String _methodName;

  /// The tag operation list.
  final List<Map<String, dynamic>> _operations;

  TagEditor(String methodName, MethodChannel channel)
      : _methodName = methodName,
        _operations = [],
        _channel = channel;

  /// Adds [tags] to the channel.
  void addTags(List<String> tags) {
    _operations.add({
      TAG_OPERATION_TYPE: TAG_OPERATION_ADD,
      TAG_OPERATION_TAGS: tags
    });
  }

  /// Removes [tags] from the channel.
  void removeTags(List<String> tags) {
    _operations.add({
      TAG_OPERATION_TYPE: TAG_OPERATION_REMOVE,
      TAG_OPERATION_TAGS: tags
    });
  }

  /// Applies the tag operations.
  Future<void> apply() async {
    var result = await _channel.invokeMethod(_methodName, _operations);
    _operations.clear();
    return result;
  }
}
