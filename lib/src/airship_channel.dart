import 'airship_module.dart';
import 'subscription_list_editor.dart';

class AirshipChannel {
  final AirshipModule _module;

  AirshipChannel(AirshipModule module) : this._module = module;

  /// Gets the channel ID.
  Future<String?> get identifier async {
    return await _module.channel.invokeMethod('channel#getChannelId');
  }

  /// Creates a [SubscriptionListEditor] to modify the subscription lists associated with the channel.
  SubscriptionListEditor editSubscriptionLists() {
    return SubscriptionListEditor((operations) =>
        _module.channel.invokeMethod(
            "channel#editSubscriptionLists", operations)
    );
  }

  /// Gets channel created event stream.
  Stream<ChannelCreatedEvent> get onChannelCreated {
    return _module
        .getEventStream("com.airship.flutter/event/channel_created")
        .map((dynamic value) => ChannelCreatedEvent._fromJson(value));
  }
//
// ///
// /// The [subscriptionListTypes] can contain types `channel` or `contact`.
// static Future<SubscriptionList> getSubscriptionLists(
//     List<String> subscriptionListTypes) async {
//   var lists = await (_channel.invokeMethod(
//       "getSubscriptionLists", subscriptionListTypes));
//   return SubscriptionList._fromJson(Map<String, dynamic>.from(lists));
// }
//
//

//
// /// Adds channel tags.
// static Future<void> addTags(List<String> tags) async {
//   return await _channel.invokeMethod('addTags', tags);
// }
//
// /// Removes channel tags.
// static Future<void> removeTags(List<String> tags) async {
//   return await _channel.invokeMethod('removeTags', tags);
// }
//
// /// Gets the channel tags.
// static Future<List<String>> get tags async {
//   List tags = await (_channel.invokeMethod("getTags"));
//   return tags.cast<String>();
// }
//
// /// Enables channel creation.
// static Future<void> enableChannelCreation() async {
//   return await _channel.invokeMethod('enableChannelCreation');
// }
//
// /// Creates an [AttributeEditor] to modify the channel attributes.
// static AttributeEditor editChannelAttributes() {
//   return AttributeEditor('editChannelAttributes', _channel);
// }
//
// /// Creates a [TagGroupEditor] to modify the channel tag groups.
// static TagGroupEditor editChannelTagGroups() {
//   return TagGroupEditor('editChannelTagGroups', _channel);
// }
//

//
//
// /// Creates an [AttributeEditor] to modify the channel attributes.
// ///
// /// Deprecated. Use [editChannelAttributes()] instead.
// @deprecated
// static AttributeEditor editAttributes() {
//   return AttributeEditor('editAttributes', _channel);
// }
}

/// Event fired when a channel is created.
class ChannelCreatedEvent {
  /// The channel ID.
  final String channelId;

  const ChannelCreatedEvent._internal(this.channelId);

  static ChannelCreatedEvent _fromJson(Map<Object?, Object?> json) {
    var channelId = json["channelId"] as String;
    return ChannelCreatedEvent._internal(channelId);
  }

  @override
  String toString() {
    return "ChannelCreatedEvent(channelId=$channelId)";
  }
}
