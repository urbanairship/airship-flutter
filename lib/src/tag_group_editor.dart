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

  final MethodChannel channel;

  /// The tag group type.
  final String type;

  /// The tag group operation list.
  final List<Map<String, dynamic>> operations;

  TagGroupEditor(String type, MethodChannel channel)
      : this.type = type,
        this.operations = [],
        this.channel = channel;

  /// Adds [tags] to a [group].
  void addTags(String group, List<String> tags) {
    operations.add({
      TAG_OPERATION_TYPE: TAG_OPERATION_ADD,
      TAG_OPERATION_GROUP_NAME: group,
      TAG_OPERATION_TAGS: tags
    });
  }

  /// Removes [tags] from a [group].
  void removeTags(String group, List<String> tags) {
    operations.add({
      TAG_OPERATION_TYPE: TAG_OPERATION_REMOVE,
      TAG_OPERATION_GROUP_NAME: group,
      TAG_OPERATION_TAGS: tags
    });
  }

  /// Overwrite the current set of tags on the [group].
  void setTags(String group, List<String> tags) {
    operations.add({
      TAG_OPERATION_TYPE: TAG_OPERATION_SET,
      TAG_OPERATION_GROUP_NAME: group,
      TAG_OPERATION_TAGS: tags
    });
  }

  /// Applies the tag operations.
  Future<void> apply() async {
    return await channel.invokeMethod(type, operations);
  }
}
