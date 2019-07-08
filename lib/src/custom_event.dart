import 'dart:async';
import 'airship.dart';

class CustomEvent {
  static const EVENT_NAME = "event_name";
  static const EVENT_VALUE = "event_value";
  static const PROPERTIES = "properties";
  static const TRANSACTION_ID = "transaction_id";
  static const INTERACTION_ID = "interaction_id";
  static const INTERACTION_TYPE = "interaction_type";

  final String name;
  final int value;
  var properties = new Map<String, dynamic>();
  String transactionId;
  String interactionId;
  String interactionType;

  CustomEvent(String name, int value)
      : this.name = name,
        this.value = value;

  Map<String, dynamic> toMap() {
    return {
      EVENT_NAME:name,
      EVENT_VALUE:value,
      PROPERTIES:properties,
      TRANSACTION_ID:transactionId,
      INTERACTION_ID:interactionId,
      INTERACTION_TYPE:interactionType
    };
  }
}
