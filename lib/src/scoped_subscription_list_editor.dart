import 'dart:async';
import 'package:flutter/services.dart';

class ScopedSubscriptionListEditor {
  static const SUBSCRIPTIONLIST_OPERATION_ID = "listid";
  static const SUBSCRIPTIONLIST_OPERATION_TYPE = "type";
  static const SUBSCRIPTIONLIST_OPERATION_SUBSCRIBE = "subscribe";
  static const SUBSCRIPTIONLIST_OPERATION_UNSUBSCRIBE = "unsubscribe";
  static const SUBSCRIPTIONLIST_OPERATION_SCOPE = "scopes";

  final MethodChannel channel;
  final String type;
  final List<Map<String, dynamic>> operations;

  ScopedSubscriptionListEditor(String type, MethodChannel channel)
      : this.type = type,
        this.operations = [],
        this.channel = channel;

  void subscribe(String listId, List<String> scopes) {
    operations.add({
      SUBSCRIPTIONLIST_OPERATION_TYPE: SUBSCRIPTIONLIST_OPERATION_SUBSCRIBE,
      SUBSCRIPTIONLIST_OPERATION_ID: listId,
      SUBSCRIPTIONLIST_OPERATION_SCOPE: scopes
    });
  }

  void unsubscribe(String listId, List<String> scopes) {
    operations.add({
      SUBSCRIPTIONLIST_OPERATION_TYPE: SUBSCRIPTIONLIST_OPERATION_UNSUBSCRIBE,
      SUBSCRIPTIONLIST_OPERATION_ID: listId,
      SUBSCRIPTIONLIST_OPERATION_SCOPE: scopes
    });
  }
  
  Future<void> apply() async {
    return await channel.invokeMethod(type, operations);
  }
}
