import 'airship_module.dart';
import 'attribute_editor.dart';
import 'scoped_subscription_list_editor.dart';
import 'tag_group_editor.dart';
import 'subscription_list.dart';

class AirshipContact {

  final AirshipModule _module;

  AirshipContact(AirshipModule module) : this._module = module;

  /// The [subscriptionListTypes] can contain types `channel` or `contact`.
  Future<SubscriptionList> getSubscriptionLists(
      List<String> subscriptionListTypes) async {
    var lists = await (_module.channel.invokeMethod(
        "contact#getSubscriptionLists", subscriptionListTypes));
    return SubscriptionList.fromJson(Map<String, dynamic>.from(lists));
  }


  /// Gets the named user.
  Future<String?> get namedUserId async {
    return await _module.channel.invokeMethod('contact#getNamedUserId');
  }

  /// Identifies the contact with a named user Id.
  Future<void> identify(String namedUser) async {
    return await _module.channel.invokeMethod('contact#identify', namedUser);
  }

  /// Resets the contact.
  Future<void> reset() async {
    return await _module.channel.invokeMethod('contact#reset');
  }


  /// Creates an [AttributeEditor] to modify the named user attributes.
  AttributeEditor editAttributes() {
    return AttributeEditor('contact#editAttributes', _module.channel);
  }


  /// Creates a [ScopedSubscriptionListEditor] to modify the subscription lists associated with the current contact.
  ScopedSubscriptionListEditor editSubscriptionLists() {
    return ScopedSubscriptionListEditor(
        'contact#editSubscriptionLists', _module.channel);
  }

  /// Creates a [TagGroupEditor] to modify the named user tag groups.
  TagGroupEditor editTagGroups() {
    return TagGroupEditor('contact#editTagGroups', _module.channel);
  }

}