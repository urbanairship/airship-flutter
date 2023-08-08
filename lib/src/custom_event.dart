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
  final String? transactionId;

  /// The event interaction ID.
  final String? interactionId;

  /// The event interaction type.
  final String? interactionType;

  /// The event properties.
  final Map<String, dynamic>? properties;

  CustomEvent({required this.name, this.value, this.transactionId, this.interactionId, this.interactionType, this.properties});

  Map<String, dynamic> toJSON() {
    return {
      EVENT_NAME: name,
      EVENT_VALUE: value,
      PROPERTIES: properties,
      TRANSACTION_ID: transactionId,
      INTERACTION_ID: interactionId,
      INTERACTION_TYPE: interactionType
    };
  }
}
