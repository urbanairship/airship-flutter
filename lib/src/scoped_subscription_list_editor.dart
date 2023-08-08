import 'dart:async';
import 'channel_scope.dart';
import 'airship_utils.dart';
import 'package:flutter/services.dart';

/// Scoped subscription list editor.
class ScopedSubscriptionListEditor {
  static const SUBSCRIPTIONLIST_OPERATION_ID = "listId";
  static const SUBSCRIPTIONLIST_OPERATION_ACTION = "action";
  static const SUBSCRIPTIONLIST_OPERATION_SUBSCRIBE = "subscribe";
  static const SUBSCRIPTIONLIST_OPERATION_UNSUBSCRIBE = "unsubscribe";
  static const SUBSCRIPTIONLIST_OPERATION_SCOPE = "scope";

  final MethodChannel channel;

  /// The subscription list update type.
  final String type;

  /// The subscription list updates.
  final List<Map<String, dynamic>> operations;

  ScopedSubscriptionListEditor(String type, MethodChannel channel)
      : this.type = type,
        this.operations = [],
        this.channel = channel;

  /// Subscribes to a list in the given [scope].
  void subscribe(String listId, ChannelScope scope) {
    var scopeString = AirshipUtils.toChannelScopeString(scope);
    operations.add({
      SUBSCRIPTIONLIST_OPERATION_ACTION: SUBSCRIPTIONLIST_OPERATION_SUBSCRIBE,
      SUBSCRIPTIONLIST_OPERATION_ID: listId,
      SUBSCRIPTIONLIST_OPERATION_SCOPE: scopeString
    });
  }

  /// Unsubscribe from a list in the given [scope].
  void unsubscribe(String listId, ChannelScope scope) {
    var scopeString = AirshipUtils.toChannelScopeString(scope);
    operations.add({
      SUBSCRIPTIONLIST_OPERATION_ACTION: SUBSCRIPTIONLIST_OPERATION_UNSUBSCRIBE,
      SUBSCRIPTIONLIST_OPERATION_ID: listId,
      SUBSCRIPTIONLIST_OPERATION_SCOPE: scopeString
    });
  }

  /// Applies subscription list changes.
  Future<void> apply() async {
    return await channel.invokeMethod(type, operations);
  }
}
