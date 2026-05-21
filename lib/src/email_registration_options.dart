/// Options for registering an email channel.
class EmailRegistrationOptions {
  /// Millisecond timestamp for transactional opted-in date.
  final int? transactionalOptedIn;

  /// Millisecond timestamp for commercial opted-in date.
  final int? commercialOptedIn;

  /// Optional properties associated with the registration.
  final Map<String, String>? properties;

  /// Whether double opt-in is enabled.
  final bool doubleOptIn;

  EmailRegistrationOptions._({
    this.transactionalOptedIn,
    this.commercialOptedIn,
    this.properties,
    this.doubleOptIn = false,
  });

  /// Creates options for a standard (non-commercial) email registration.
  factory EmailRegistrationOptions.options({
    int? transactionalOptedIn,
    Map<String, String>? properties,
    bool doubleOptIn = false,
  }) {
    return EmailRegistrationOptions._(
      transactionalOptedIn: transactionalOptedIn,
      properties: properties,
      doubleOptIn: doubleOptIn,
    );
  }

  /// Creates options for a commercial email registration.
  factory EmailRegistrationOptions.commercial({
    required int commercialOptedIn,
    int? transactionalOptedIn,
    Map<String, String>? properties,
  }) {
    return EmailRegistrationOptions._(
      transactionalOptedIn: transactionalOptedIn,
      commercialOptedIn: commercialOptedIn,
      properties: properties,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'doubleOptIn': doubleOptIn,
    };
    if (transactionalOptedIn != null) {
      map['transactionalOptedIn'] = transactionalOptedIn;
    }
    if (commercialOptedIn != null) {
      map['commercialOptedIn'] = commercialOptedIn;
    }
    if (properties != null) {
      map['properties'] = properties;
    }
    return map;
  }
}
