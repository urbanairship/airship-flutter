import 'dart:async';
import 'package:flutter/services.dart';

class SubscriptionListEditor {
  static const SUBSCRIPTIONLIST_OPERATION_ID = "listid";
  static const SUBSCRIPTIONLIST_OPERATION_TYPE = "type";
  static const SUBSCRIPTIONLIST_OPERATION_SUBSCRIBE = "subscribe";
  static const SUBSCRIPTIONLIST_OPERATION_UNSUBSCRIBE = "unsubscribe";

  final MethodChannel channel;
  final String type;
  final List<Map<String, dynamic>> operations;

  SubscriptionListEditor(String type, MethodChannel channel)
      : this.type = type,
        this.operations = [],
        this.channel = channel;

  void subscribe(String listId) {
    operations.add({
      SUBSCRIPTIONLIST_OPERATION_TYPE: SUBSCRIPTIONLIST_OPERATION_SUBSCRIBE,
      SUBSCRIPTIONLIST_OPERATION_ID: listId
    });
  }

  void unsubscribe(String listId) {
    operations.add({
      SUBSCRIPTIONLIST_OPERATION_TYPE: SUBSCRIPTIONLIST_OPERATION_UNSUBSCRIBE,
      SUBSCRIPTIONLIST_OPERATION_ID: listId
    });
  }
  
  Future<void> apply() async {
    return await channel.invokeMethod(type, operations);
  }
}
