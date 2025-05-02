import 'dart:async';
import 'package:flutter/services.dart';

/// Editor for attributes.
class AttributeEditor {
  static const ATTRIBUTE_OPERATION_KEY = "key";
  static const ATTRIBUTE_OPERATION_TYPE = "action";
  static const ATTRIBUTE_OPERATION_REMOVE = "remove";
  static const ATTRIBUTE_OPERATION_SET = "set";
  static const ATTRIBUTE_OPERATION_VALUE = "value";
  static const ATTRIBUTE_OPERATION_VALUE_TYPE = "type";
  static const ATTRIBUTE_OPERATION_INSTANCE_ID = "instance_id";
  static const ATTRIBUTE_OPERATION_EXPIRATION_MS = "expiration_milliseconds";

  final MethodChannel channel;

  /// The attribute type, if available.
  final String type;

  /// The attribute operation list.
  final List<Map<String, dynamic>> operations;

  AttributeEditor(this.type, this.channel) : operations = [];

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
      ATTRIBUTE_OPERATION_VALUE: value,
      ATTRIBUTE_OPERATION_VALUE_TYPE: "string"
    });
  }

  /// Adds a number attribute.
  void setNumberAttribute(String name, num value) {
    operations.add({
      ATTRIBUTE_OPERATION_TYPE: ATTRIBUTE_OPERATION_SET,
      ATTRIBUTE_OPERATION_KEY: name,
      ATTRIBUTE_OPERATION_VALUE: value,
      ATTRIBUTE_OPERATION_VALUE_TYPE: "number"
    });
  }

  /// Adds a date attribute.
  void setDateAttribute(String name, DateTime value) {
    operations.add({
      ATTRIBUTE_OPERATION_TYPE: ATTRIBUTE_OPERATION_SET,
      ATTRIBUTE_OPERATION_KEY: name,
      ATTRIBUTE_OPERATION_VALUE: value.millisecondsSinceEpoch,
      ATTRIBUTE_OPERATION_VALUE_TYPE: "date"
    });
  }

  /// Adds a JSON attribute.
  ///
  /// @param name The attribute name.
  /// @param instanceId The instance ID.
  /// @param json The json value.
  /// @param expiration Optional expiration date.
  void setJsonAttribute(
      String name, String instanceId, Map<String, dynamic> json,
      [DateTime? expiration]) {
    final operation = {
      ATTRIBUTE_OPERATION_TYPE: ATTRIBUTE_OPERATION_SET,
      ATTRIBUTE_OPERATION_KEY: name,
      ATTRIBUTE_OPERATION_INSTANCE_ID: instanceId,
      ATTRIBUTE_OPERATION_VALUE: json,
      ATTRIBUTE_OPERATION_VALUE_TYPE: "json"
    };

    if (expiration != null) {
      operation[ATTRIBUTE_OPERATION_EXPIRATION_MS] =
          expiration.millisecondsSinceEpoch;
    }

    operations.add(operation);
  }

  /// Removes a JSON attribute.
  ///
  /// @param name The attribute name.
  /// @param instanceId The instance ID.
  void removeJsonAttribute(String name, String instanceId) {
    operations.add({
      ATTRIBUTE_OPERATION_TYPE: ATTRIBUTE_OPERATION_REMOVE,
      ATTRIBUTE_OPERATION_KEY: name,
      ATTRIBUTE_OPERATION_INSTANCE_ID: instanceId
    });
  }

  /// Applies the attribute operations.
  Future<void> apply() async {
    return await channel.invokeMethod(type, operations);
  }
}
