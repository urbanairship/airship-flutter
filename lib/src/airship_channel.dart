import 'airship_module.dart';
import 'attribute_editor.dart';
import 'subscription_list_editor.dart';
import 'tag_group_editor.dart';
import 'subscription_list.dart';

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


  /// Gets channel subscription lists.
  Future<SubscriptionList> getSubscriptionLists() async {
    var lists = await (_module.channel.invokeMethod(
        "channel#getSubscriptionLists"));
    return SubscriptionList.fromJson(Map<String, dynamic>.from(lists));
  }

  /// Adds channel tags.
  Future<void> addTags(List<String> tags) async {
    return await _module.channel.invokeMethod('channel#addTags', tags);
  }

  /// Removes channel tags.
  Future<void> removeTags(List<String> tags) async {
    return await _module.channel.invokeMethod('channel#removeTags', tags);
  }

  /// Gets the channel tags.
  Future<List<String>> get tags async {
    List tags = await (_module.channel.invokeMethod("channel#getTags"));
    return tags.cast<String>();
  }

  /// Enables channel creation.
  Future<void> enableChannelCreation() async {
    return await _module.channel.invokeMethod('channel#enableChannelCreation');
  }

  /// Creates an [AttributeEditor] to modify the channel attributes.
  AttributeEditor editChannelAttributes() {
    return AttributeEditor('channel#editChannelAttributes', _module.channel);
  }

  /// Creates a [TagGroupEditor] to modify the channel tag groups.
  TagGroupEditor editChannelTagGroups() {
    return TagGroupEditor('channel#editChannelTagGroups', _module.channel);
  }

  /// Creates an [AttributeEditor] to modify the channel attributes.
  ///
  /// Deprecated. Use [editChannelAttributes()] instead.
  @deprecated
  AttributeEditor editAttributes() {
    return AttributeEditor('channel#editAttributes', _module.channel);
  }
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
