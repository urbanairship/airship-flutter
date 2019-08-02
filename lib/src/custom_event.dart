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
  String transactionId;
  String interactionId;
  String interactionType;

  var _properties = new Map<String, dynamic>();

  CustomEvent(String name, int value)
      : this.name = name,
        this.value = value;

  /**
   * Sets a custom BOOL property.
   *
   * @param value The property value.
   * @param key The property key.
   */
  void setBoolProperty(String key, bool value) {
    _properties[key] = value;
  }

  /**
   * Sets a custom String property. The value's length must not exceed 255 characters
   * or it will invalidate the event.
   *
   * @param value The property value.
   * @param key The property key.
   */
  void setStringProperty(String key, String value) {
    _properties[key] = value;
  }

  /**
   * Sets a custom Number property.
   *
   * @param value The property value.
   * @param key The property key.
   */
  void setNumberProperty(String key, int value) {
    _properties[key] = value;
  }

  /**
   * Sets a custom String list property. The list must not exceed 20 entries and
   * each entry's length must not exceed 255 characters or it will invalidate the event.
   *
   * @param value The property value.
   * @param key The property key.
   */
  void setStringArrayProperty(String key, List<String> arr) {
    _properties[key] = arr;
  }


  Map<String, dynamic> toMap() {
    return {
      EVENT_NAME:name,
      EVENT_VALUE:value,
      PROPERTIES:_properties,
      TRANSACTION_ID:transactionId,
      INTERACTION_ID:interactionId,
      INTERACTION_TYPE:interactionType
    };
  }
}
