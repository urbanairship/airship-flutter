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

  ///
  /// Adds a custom event property.
  ///
  /// @param key The property key.
  /// @param value The property value.
  ///
  void addProperty(String key, dynamic value) {
    if (key == null) {
      throw ArgumentError.notNull('key');
    }
    if (value == null) {
      throw ArgumentError.notNull('value');
    }
    _properties[key] = value;
  }

  ///
  /// Sets custom event properties.
  ///
  /// @param properties The custom event properties.
  ///
  void setProperties(Map<String, dynamic> properties) {
    if (properties == null) {
      throw ArgumentError.notNull('properties');
    }
    properties.forEach((key,value) => _properties[key] = value);
  }

  Map<String, dynamic> toMap() {
    return {
      EVENT_NAME: name,
      EVENT_VALUE: value,
      PROPERTIES: _properties,
      TRANSACTION_ID: transactionId,
      INTERACTION_ID: interactionId,
      INTERACTION_TYPE: interactionType
    };
  }
}
