/// Custom event object.
class CustomEvent {
  static const EVENT_NAME = "eventName";
  static const EVENT_VALUE = "eventValue";
  static const PROPERTIES = "properties";
  static const TRANSACTION_ID = "transactionId";
  static const INTERACTION_ID = "interactionId";
  static const INTERACTION_TYPE = "interactionType";

  /// The event name.
  final String name;

  /// The event value.
  final double? value;

  /// The event transaction ID.
  String? transactionId;

  /// The event interaction ID.
  String? interactionId;

  /// The event interaction type.
  String? interactionType;

  /// The event properties.
  Map<String, dynamic>? properties;

  CustomEvent({required this.name, this.value, this.transactionId, this.interactionId, this.interactionType, this.properties});


  Map<String, dynamic> toJSON() {
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
