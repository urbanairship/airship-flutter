import 'dart:async';
import 'package:flutter/services.dart';

/// Scoped subscription list editor.
class ScopedSubscriptionListEditor {
  static const SUBSCRIPTIONLIST_OPERATION_ID = "listId";
  static const SUBSCRIPTIONLIST_OPERATION_TYPE = "type";
  static const SUBSCRIPTIONLIST_OPERATION_SUBSCRIBE = "subscribe";
  static const SUBSCRIPTIONLIST_OPERATION_UNSUBSCRIBE = "unsubscribe";
  static const SUBSCRIPTIONLIST_OPERATION_SCOPE = "scopes";

  final MethodChannel channel;

  /// The subscription list update type.
  final String type;

  /// The subscription list updates.
  final List<Map<String, dynamic>> operations;

  ScopedSubscriptionListEditor(String type, MethodChannel channel)
      : this.type = type,
        this.operations = [],
        this.channel = channel;

  /// Subscribes to a list in the given [scopes].
  void subscribe(String listId, List<String> scopes) {
    operations.add({
      SUBSCRIPTIONLIST_OPERATION_TYPE: SUBSCRIPTIONLIST_OPERATION_SUBSCRIBE,
      SUBSCRIPTIONLIST_OPERATION_ID: listId,
      SUBSCRIPTIONLIST_OPERATION_SCOPE: scopes
    });
  }

  /// Unsubscribe from a list in the given [scopes].
  void unsubscribe(String listId, List<String> scopes) {
    operations.add({
      SUBSCRIPTIONLIST_OPERATION_TYPE: SUBSCRIPTIONLIST_OPERATION_UNSUBSCRIBE,
      SUBSCRIPTIONLIST_OPERATION_ID: listId,
      SUBSCRIPTIONLIST_OPERATION_SCOPE: scopes
    });
  }

  /// Applies subscription list changes.
  Future<void> apply() async {
    return await channel.invokeMethod(type, operations);
  }
}
