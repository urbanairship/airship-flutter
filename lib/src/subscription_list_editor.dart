import 'dart:async';
import 'package:flutter/services.dart';

/// Subscription list editor.
class SubscriptionListEditor {

  /// The channel
  final MethodChannel _channel;

  /// The subscription list update type.
  final String _methodName;

  /// The subscription list updates.
  final List<Map<String, dynamic>> _operations;

  SubscriptionListEditor(String methodName, MethodChannel channel)
      : _methodName = methodName,
        _operations = [],
        _channel = channel;

  
  /// Subscribes to a list
  void subscribe(String listId) {
    _addOperation(listId, "subscribe");
  }

  /// Unsubscribe from a list
  void unsubscribe(String listId) {
    _addOperation(listId, "unsubscribe");
  }

  void _addOperation(String listId, String action) {
    _operations.add({"action": action, "listId": listId});
  }

  /// Applies subscription list changes.
  Future<void> apply() async {
    var result = await _channel.invokeMethod(_methodName, _operations);
    _operations.clear();
    return result;
  }
}
