import 'airship_module.dart';
import 'attribute_editor.dart';
import 'scoped_subscription_list_editor.dart';
import 'tag_group_editor.dart';
import 'channel_scope.dart';
import 'airship_utils.dart';

class AirshipContact {

  final AirshipModule _module;

  AirshipContact(AirshipModule module) : _module = module;

  /// Gets the contacts subscription lists.
  Future<Map<String, List<ChannelScope>>> get subscriptionLists async {
    var payload = await (_module.channel.invokeMethod(
        "contact#getSubscriptionLists"));

    payload.forEach((key, value) {
      List<String> parsedValue = List<String>.from(value);
      List<ChannelScope> scopeList = <ChannelScope>[];
      for (var scopeString in parsedValue) {
        scopeList.add(AirshipUtils.parseChannelScope(scopeString));
      }
      payload[key] = scopeList;
    });
    return Map<String, List<ChannelScope>>.from(payload);
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

    /// Notifies the contact of a remote login.
  Future<void> notifyRemoteLogin() async {
    return await _module.channel.invokeMethod('contact#notifyRemoteLogin');
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