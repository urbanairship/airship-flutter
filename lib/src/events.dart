
/// Event fired when the user initiates a notification response.
class NotificationResponseEvent {
  /// The action button ID, if available.
  final String? actionId;

  /// Indicates whether the response was a foreground action.
  ///
  /// This value is always if the user taps the main notification,
  /// otherwise it is defined by the notification action button.
  final bool? isForeground;

  /// The push [Notification].
  final Notification notification;

  /// The notification payload.
  final Map<String, dynamic>? payload;

  const NotificationResponseEvent._internal(
      this.actionId, this.isForeground, this.notification, this.payload);

  static NotificationResponseEvent _fromJson(Map<String, dynamic> json) {
    var actionId = json["action_id"];
    var isForeground = json["is_foreground"];
    var notification = Notification._fromJson(json["notification"]);
    var payload = json["payload"];
    return NotificationResponseEvent._internal(
        actionId, isForeground, notification, payload);
  }

  @override
  String toString() {
    return "NotificationResponseEvent(actionId=$actionId, isForeground=$isForeground, notification=$notification, payload=$payload)";
  }
}

/// Event fired when a push is received.
class PushReceivedEvent {
  /// The notification payload.
  final Map<String, dynamic>? payload;

  /// The push [Notification].
  final Notification? notification;

  const PushReceivedEvent._internal(this.payload, this.notification);

  static PushReceivedEvent _fromJson(Map<String, dynamic> json) {
    var payload = json["payload"];

    var notification;
    if (json["notification"] != null) {
      notification = Notification._fromJson(json["notification"]);
    }

    return PushReceivedEvent._internal(payload, notification);
  }

  @override
  String toString() {
    return "PushReceivedEvent(payload=$payload, notification=$notification)";
  }
}

@pragma('vm:entry-point')
void _backgroundMessageIsolateCallback() {
  WidgetsFlutterBinding.ensureInitialized();

  Airship._backgroundChannel.setMethodCallHandler((call) async {
    if (call.method == "onBackgroundMessage") {
      final args = call.arguments;
      final handle = CallbackHandle.fromRawHandle(args["messageCallback"]);
      final callback = PluginUtilities.getCallbackFromHandle(handle)
      as BackgroundMessageHandler;
      try {
        final payload = Map<String, dynamic>.from(jsonDecode(args["payload"]));
        var notification;
        if (args["notification"] != null) {
          notification =
              Notification._fromJson(jsonDecode(args["notification"]));
        }
        await callback(payload, notification);
      } catch (e) {
        print("Airship: Failed to handle background message!");
        print(e);
      }
    } else {
      throw UnimplementedError("${call.method} is not implemented!");
    }
  });

  // Tell the native side to start the background isolate.
  Airship._backgroundChannel.invokeMethod<void>("backgroundIsolateStarted");
}

typedef BackgroundMessageHandler = Future<void> Function(
    Map<String, dynamic> payload, Notification? notification);

