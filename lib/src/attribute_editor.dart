import 'dart:async';
import 'package:flutter/services.dart';

class AttributeEditor {
  static const ATTRIBUTE_OPERATION_KEY = "key";
  static const ATTRIBUTE_OPERATION_TYPE = "action";
  static const ATTRIBUTE_OPERATION_REMOVE = "remove";
  static const ATTRIBUTE_OPERATION_SET = "set";
  static const ATTRIBUTE_OPERATION_VALUE = "value";

  final MethodChannel channel;
  final String type;
  final List<Map<String, dynamic>> operations;

  AttributeEditor(String type, MethodChannel channel)
      : this.type = type,
        this.operations = new List(),
        this.channel = channel;

  void removeAttribute(String name) {
    operations.add({ATTRIBUTE_OPERATION_TYPE:ATTRIBUTE_OPERATION_REMOVE, ATTRIBUTE_OPERATION_KEY:name});
  }

  void setAttribute(String name, String value) {
    operations.add({ATTRIBUTE_OPERATION_TYPE:ATTRIBUTE_OPERATION_SET, ATTRIBUTE_OPERATION_KEY:name, ATTRIBUTE_OPERATION_VALUE:value});
  }

  Future<void> apply() async {
    if (operations == null) {
      throw ArgumentError.notNull('operations');
    }
    return await channel.invokeMethod(type, operations);
  }
}