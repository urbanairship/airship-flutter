/// Options for registering an SMS channel.
class SmsRegistrationOptions {
  /// The sender ID to associate with the SMS registration.
  final String senderId;

  SmsRegistrationOptions({required this.senderId});

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
    };
  }
}
