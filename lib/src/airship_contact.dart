// class AirshipContact {
//
//   const MethodChannel _channel;
//
//   const AirshipContact._internal(this._channel)
//
//   ///
//   /// The [subscriptionListTypes] can contain types `channel` or `contact`.
//   static Future<SubscriptionList> getSubscriptionLists(
//       List<String> subscriptionListTypes) async {
//     var lists = await (_channel.invokeMethod(
//         "getSubscriptionLists", subscriptionListTypes));
//     return SubscriptionList._fromJson(Map<String, dynamic>.from(lists));
//   }
//
//
//   /// Gets the named user.
//   static Future<String?> get namedUser async {
//     return await _channel.invokeMethod('getNamedUser');
//   }
//
//
//   /// Creates an [AttributeEditor] to modify the named user attributes.
//   static AttributeEditor editNamedUserAttributes() {
//     return AttributeEditor('editNamedUserAttributes', _channel);
//   }
//
//
//   /// Creates a [ScopedSubscriptionListEditor] to modify the subscription lists associated with the current contact.
//   static ScopedSubscriptionListEditor editContactSubscriptionLists() {
//     return ScopedSubscriptionListEditor(
//         'editContactSubscriptionLists', _channel);
//   }
//
//
//
//   /// Creates a [TagGroupEditor] to modify the named user tag groups.
//   static TagGroupEditor editNamedUserTagGroups() {
//     return TagGroupEditor('editNamedUserTagGroups', _channel);
//   }
//
//   /// Sets the named user.
//   ///
//   /// Set [namedUser] at null to clear the named user.
//   static Future<void> setNamedUser(String? namedUser) async {
//     return await _channel.invokeMethod('setNamedUser', namedUser);
//   }
//
// }