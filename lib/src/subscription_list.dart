/// Subscription list object.
class SubscriptionList {
  /// Channel subscription lists.
  final List<String>? channelSubscriptionLists;

  /// Contact subscription lists.
  final List<ContactSubscriptionList>? contactSubscriptionLists;

  const SubscriptionList._internal(
      this.channelSubscriptionLists, this.contactSubscriptionLists);

  static SubscriptionList fromJson(Map<String, dynamic> json) {
    var channelSubscriptionLists = <String>[];
    if (json["channel"] != null) {
      channelSubscriptionLists = List<String>.from(json["channel"]);
    }
    var contactSubscriptionLists = <ContactSubscriptionList>[];
    if (json["contact"] != null) {
      var lists = Map<String, dynamic>.from(json["contact"]);
      lists.forEach((k, v) => contactSubscriptionLists
          .add(ContactSubscriptionList._fromJson(k, List<String>.from(v))));
    }

    return SubscriptionList._internal(
        channelSubscriptionLists, contactSubscriptionLists);
  }

  @override
  String toString() {
    return "SubscriptionList(channelSubscriptionLists=$channelSubscriptionLists, contactSubscriptionLists=$contactSubscriptionLists)";
  }
}

/// Contact subscription list object.
class ContactSubscriptionList {
  /// The contact subscription list identifier.
  final String identifier;

  /// The contact subscription list scope.
  final List<String> scopes;

  const ContactSubscriptionList._internal(this.identifier, this.scopes);

  static ContactSubscriptionList _fromJson(
      String identifier, List<String> scopes) {
    return ContactSubscriptionList._internal(identifier, scopes);
  }

  @override
  String toString() {
    return "ContactSubscriptionList(identifier=$identifier, scopes=$scopes)";
  }
}