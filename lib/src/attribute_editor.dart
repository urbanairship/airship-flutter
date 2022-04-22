import 'dart:async';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Editor for attributes.
class AttributeEditor {
  static const ATTRIBUTE_OPERATION_KEY = "key";
  static const ATTRIBUTE_OPERATION_TYPE = "action";
  static const ATTRIBUTE_OPERATION_REMOVE = "remove";
  static const ATTRIBUTE_OPERATION_SET = "set";
  static const ATTRIBUTE_OPERATION_VALUE = "value";

  final MethodChannel channel;

  /// The attribute type, if available.
  final String type;

  /// The attribute operation list.
  final List<Map<String, dynamic>> operations;

  AttributeEditor(String type, MethodChannel channel)
      : this.type = type,
        this.operations = [],
        this.channel = channel;

  /// Removes an attribute.
  void removeAttribute(String name) {
    operations.add({
      ATTRIBUTE_OPERATION_TYPE: ATTRIBUTE_OPERATION_REMOVE,
      ATTRIBUTE_OPERATION_KEY: name
    });
  }

  /// Adds a text attribute.
  void setAttribute(String name, String value) {
    operations.add({
      ATTRIBUTE_OPERATION_TYPE: ATTRIBUTE_OPERATION_SET,
      ATTRIBUTE_OPERATION_KEY: name,
      ATTRIBUTE_OPERATION_VALUE: value
    });
  }

  /// Adds a number attribute.
  void setNumberAttribute(String name, num value) {
    operations.add({
      ATTRIBUTE_OPERATION_TYPE: ATTRIBUTE_OPERATION_SET,
      ATTRIBUTE_OPERATION_KEY: name,
      ATTRIBUTE_OPERATION_VALUE: value
    });
  }

  /// Adds a date attribute.
  void setDateAttribute(String name, DateTime value) {
    var dateFormatter = new DateFormat('yyyy-MM-ddTHH:mm:ss');
    String dateString = dateFormatter.format(value);

    operations.add({
      ATTRIBUTE_OPERATION_TYPE: ATTRIBUTE_OPERATION_SET,
      ATTRIBUTE_OPERATION_KEY: name,
      ATTRIBUTE_OPERATION_VALUE: dateString
    });
  }

  /// Applies the attribute operations.
  Future<void> apply() async {
    return await channel.invokeMethod(type, operations);
  }
}
