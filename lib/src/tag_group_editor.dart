import 'dart:async';
import 'package:flutter/services.dart';

class TagGroupEditor {
  static const TAG_OPERATION_ADD = "add";
  static const TAG_OPERATION_REMOVE = "remove";
  static const TAG_OPERATION_SET = "set";

  static const TAG_OPERATION_GROUP_NAME = "group";
  static const TAG_OPERATION_TAGS = "tags";
  static const TAG_OPERATION_TYPE = "operationType";

  final MethodChannel channel;
  final String type;
  final List<Map<String, dynamic>> operations;

  TagGroupEditor(String type, MethodChannel channel)
      : this.type = type,
        this.operations = new List(),
        this.channel = channel;
  
  void addTags(String group, List<String> tags) {
    operations.add({TAG_OPERATION_TYPE:TAG_OPERATION_ADD, TAG_OPERATION_GROUP_NAME:group, TAG_OPERATION_TAGS:tags});
  }

  void removeTags(String group, List<String> tags) {
    operations.add({TAG_OPERATION_TYPE:TAG_OPERATION_REMOVE, TAG_OPERATION_GROUP_NAME:group, TAG_OPERATION_TAGS:tags});
  }

  void setTags(String group, List<String> tags) {
    operations.add({TAG_OPERATION_TYPE:TAG_OPERATION_SET, TAG_OPERATION_GROUP_NAME:group, TAG_OPERATION_TAGS:tags});
  }

  Future<void> apply() async {
    if (operations == null) {
      throw ArgumentError.notNull('operations');
    }
    return await channel.invokeMethod(type, operations);
  }
}