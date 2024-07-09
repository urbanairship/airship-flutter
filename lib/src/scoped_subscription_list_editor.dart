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

  final MethodChannel _channel;

  /// The subscription list update type.
  final String _methodName;

  /// The subscription list updates.
  final List<Map<String, dynamic>> _operations;

  ScopedSubscriptionListEditor(String methodName, MethodChannel channel)
      : _methodName = methodName,
        _operations = [],
        _channel = channel;

  /// Subscribes to a list in the given [scope].
  void subscribe(String listId, ChannelScope scope) {
    var scopeString = AirshipUtils.toChannelScopeString(scope);
    _operations.add({
      SUBSCRIPTIONLIST_OPERATION_ACTION: SUBSCRIPTIONLIST_OPERATION_SUBSCRIBE,
      SUBSCRIPTIONLIST_OPERATION_ID: listId,
      SUBSCRIPTIONLIST_OPERATION_SCOPE: scopeString
    });
  }

  /// Unsubscribe from a list in the given [scope].
  void unsubscribe(String listId, ChannelScope scope) {
    var scopeString = AirshipUtils.toChannelScopeString(scope);
    _operations.add({
      SUBSCRIPTIONLIST_OPERATION_ACTION: SUBSCRIPTIONLIST_OPERATION_UNSUBSCRIBE,
      SUBSCRIPTIONLIST_OPERATION_ID: listId,
      SUBSCRIPTIONLIST_OPERATION_SCOPE: scopeString
    });
  }

  /// Applies subscription list changes.
  Future<void> apply() async {
    var result = await _channel.invokeMethod(_methodName, _operations);
    _operations.clear();
    return result;
  }
}
