import 'dart:async';
import 'package:flutter/services.dart';

/// Subscription list editor.
class SubscriptionListEditor {
  static const SUBSCRIPTIONLIST_OPERATION_ID = "listId";
  static const SUBSCRIPTIONLIST_OPERATION_TYPE = "type";
  static const SUBSCRIPTIONLIST_OPERATION_SUBSCRIBE = "subscribe";
  static const SUBSCRIPTIONLIST_OPERATION_UNSUBSCRIBE = "unsubscribe";

  final MethodChannel channel;

  /// The subscription list update type.
  final String type;

  /// The subscription list updates.
  final List<Map<String, dynamic>> operations;

  SubscriptionListEditor(String type, MethodChannel channel)
      : this.type = type,
        this.operations = [],
        this.channel = channel;

  /// Subscribes to a list
  void subscribe(String listId) {
    operations.add({
      SUBSCRIPTIONLIST_OPERATION_TYPE: SUBSCRIPTIONLIST_OPERATION_SUBSCRIBE,
      SUBSCRIPTIONLIST_OPERATION_ID: listId
    });
  }

  /// Unsubscribe from a list
  void unsubscribe(String listId) {
    operations.add({
      SUBSCRIPTIONLIST_OPERATION_TYPE: SUBSCRIPTIONLIST_OPERATION_UNSUBSCRIBE,
      SUBSCRIPTIONLIST_OPERATION_ID: listId
    });
  }

  /// Applies subscription list changes.
  Future<void> apply() async {
    return await channel.invokeMethod(type, operations);
  }
}
