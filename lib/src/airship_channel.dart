import 'airship_module.dart';
import 'attribute_editor.dart';
import 'subscription_list_editor.dart';
import 'tag_group_editor.dart';
import 'tag_editor.dart';
import 'airship_events.dart';

class AirshipChannel {
  final AirshipModule _module;

  AirshipChannel(AirshipModule module) : _module = module;

  /// Gets the channel ID.
  Future<String?> get identifier async {
    return await _module.channel.invokeMethod('channel#getChannelId');
  }

  /// Returns the channel ID. If the channel ID is not yet created the function it will wait for it before returning. After
  /// the channel ID is created, this method functions the same as `identifier`.
  /// 
  /// @returns A future with the channel ID.
  Future<String> waitForChannelId() async {
    return await _module.channel.invokeMethod('channel#waitForChannelId');
  }

  /// Creates a [SubscriptionListEditor] to modify the subscription lists associated with the channel.
  SubscriptionListEditor editSubscriptionLists() {
    return SubscriptionListEditor("channel#editSubscriptionLists", _module.channel);
  }

  /// Gets channel created event stream.
  Stream<ChannelCreatedEvent> get onChannelCreated {
    return _module
        .getEventStream("com.airship.flutter/event/channel_created")
        .map((dynamic value) => ChannelCreatedEvent.fromJson(value));
  }

  /// Gets channel subscription lists.
  Future<List<String>> get subscriptionLists async {
    List lists = await _module.channel.invokeMethod(
        "channel#getSubscriptionLists");
    return lists.cast<String>();
  }

  /// Adds channel tags.
  /// Deprecated. Use editTags() instead.
  Future<void> addTags(List<String> tags) async {
    return await _module.channel.invokeMethod('channel#addTags', tags);
  }

  /// Removes channel tags.
  /// Deprecated. Use editTags() instead.
  Future<void> removeTags(List<String> tags) async {
    return await _module.channel.invokeMethod('channel#removeTags', tags);
  }

  /// Creates a [TagEditor] to modify the device tags.
  TagEditor editTags() {
    return TagEditor('channel#editTags', _module.channel);
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
  AttributeEditor editAttributes() {
    return AttributeEditor('channel#editAttributes', _module.channel);
  }

  /// Creates a [TagGroupEditor] to modify the channel tag groups.
  TagGroupEditor editTagGroups() {
    return TagGroupEditor('channel#editTagGroups', _module.channel);
  }
}

