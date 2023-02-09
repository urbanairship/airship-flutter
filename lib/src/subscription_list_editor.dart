import 'dart:async';

/// Subscription list editor.
class SubscriptionListEditor {

  final List<Map<String, dynamic>> _operations = [];
  final Future<void> Function(dynamic operations) _onApply;

  SubscriptionListEditor(this._onApply);

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
    var result = await this._onApply(_operations);
    _operations.clear();
    return result;
  }
}
