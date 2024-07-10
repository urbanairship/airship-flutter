import 'dart:async';
import 'package:flutter/services.dart';

/// Editor for tag groups.
class TagGroupEditor {
  static const TAG_OPERATION_ADD = "add";
  static const TAG_OPERATION_REMOVE = "remove";
  static const TAG_OPERATION_SET = "set";

  static const TAG_OPERATION_GROUP_NAME = "group";
  static const TAG_OPERATION_TAGS = "tags";
  static const TAG_OPERATION_TYPE = "operationType";

  final MethodChannel _channel;

  /// The method name.
  final String _methodName;

  /// The tag group operation list.
  final List<Map<String, dynamic>> _operations;

  TagGroupEditor(String methodName, MethodChannel channel)
      : _methodName = methodName,
        _operations = [],
        _channel = channel;

  /// Adds [tags] to a [group].
  void addTags(String group, List<String> tags) {
    _operations.add({
      TAG_OPERATION_TYPE: TAG_OPERATION_ADD,
      TAG_OPERATION_GROUP_NAME: group,
      TAG_OPERATION_TAGS: tags
    });
  }

  /// Removes [tags] from a [group].
  void removeTags(String group, List<String> tags) {
    _operations.add({
      TAG_OPERATION_TYPE: TAG_OPERATION_REMOVE,
      TAG_OPERATION_GROUP_NAME: group,
      TAG_OPERATION_TAGS: tags
    });
  }

  /// Overwrite the current set of tags on the [group].
  void setTags(String group, List<String> tags) {
    _operations.add({
      TAG_OPERATION_TYPE: TAG_OPERATION_SET,
      TAG_OPERATION_GROUP_NAME: group,
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
