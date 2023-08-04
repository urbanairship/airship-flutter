import 'notification.dart';
import 'push_notification_status.dart';
import 'package:flutter/material.dart' hide Notification;

/// Event fired when the message center should be displayed.
class DisplayMessageCenterEvent {
  // The optional message Id
  final String? messageId;

  const DisplayMessageCenterEvent._internal(this.messageId);

  static DisplayMessageCenterEvent fromJson(Map<String, dynamic> json) {
    var messageId = json["messageId"];
    return DisplayMessageCenterEvent._internal(messageId);
  }

  @override
  String toString() {
    return "DisplayMessageCenterEvent(messageId=$messageId)";
  }
}

/// Event fired when a channel is created.
class ChannelCreatedEvent {
  /// The channel ID.
  final String channelId;

  const ChannelCreatedEvent._internal(this.channelId);

  static ChannelCreatedEvent fromJson(Map<String, dynamic> json) {
    var channelId = json["channelId"] as String;
    return ChannelCreatedEvent._internal(channelId);
  }

  @override
  String toString() {
    return "ChannelCreatedEvent(channelId=$channelId)";
  }
}

/// Event fired when a deep link is received is created.
class DisplayPreferenceCenterEvent {
  /// The preference center Id.
  final String preferenceCenterId;

  const DisplayPreferenceCenterEvent._internal(this.preferenceCenterId);

  static DisplayPreferenceCenterEvent fromJson(dynamic json) {
    var preferenceCenterId = json["preferenceCenterId"] as String;
    return DisplayPreferenceCenterEvent._internal(preferenceCenterId);
  }

  @override
  String toString() {
    return "DisplayPreferenceCenterEvent(preferenceCenterId=$preferenceCenterId)";
  }
}

/// Event fired when a deep link is received is created.
class DeepLinkEvent {
  /// The deep link.
  final String deepLink;

  const DeepLinkEvent._internal(this.deepLink);

  static DeepLinkEvent fromJson(dynamic json) {
    var deepLink = json["deepLink"] as String;
    return DeepLinkEvent._internal(deepLink);
  }

  @override
  String toString() {
    return "DeepLinkEvent(deepLink=$deepLink)";
  }
}

/// Event fired when the notification status changes.
class PushNotificationStatusChangedEvent {
  // The push notification status
  final PushNotificationStatus status;

  const PushNotificationStatusChangedEvent._internal(this.status);

  static PushNotificationStatusChangedEvent fromJson(dynamic json) {
    var status = PushNotificationStatus.fromJson(json["status"]);
    return PushNotificationStatusChangedEvent._internal(status);
  }

  @override
  String toString() {
    return "PushNotificationStatusChangedEvent(status=$status)";
  }
}

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

  static NotificationResponseEvent fromJson(dynamic json) {
    var actionId = json["action_id"];
    var isForeground = json["is_foreground"];
    var notification = Notification.fromJson(json["notification"]);
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

  static PushReceivedEvent fromJson(dynamic json) {
    var payload = json["payload"];

    var notification;
    if (json["notification"] != null) {
      notification = Notification.fromJson(json["notification"]);
    }

    return PushReceivedEvent._internal(payload, notification);
  }

  @override
  String toString() {
    return "PushReceivedEvent(payload=$payload, notification=$notification)";
  }
}

@pragma('vm:entry-point')
void backgroundMessageIsolateCallback() {
  WidgetsFlutterBinding.ensureInitialized();

  // Airship._backgroundChannel.setMethodCallHandler((call) async {
  //   if (call.method == "onBackgroundMessage") {
  //     final args = call.arguments;
  //     final handle = CallbackHandle.fromRawHandle(args["messageCallback"]);
  //     final callback = PluginUtilities.getCallbackFromHandle(handle)
  //     as BackgroundMessageHandler;
  //     try {
  //       final payload = Map<String, dynamic>.from(jsonDecode(args["payload"]));
  //       var notification;
  //       if (args["notification"] != null) {
  //         notification =
  //             Notification.fromJson(jsonDecode(args["notification"]));
  //       }
  //       await callback(payload, notification);
  //     } catch (e) {
  //       print("Airship: Failed to handle background message!");
  //       print(e);
  //     }
  //   } else {
  //     throw UnimplementedError("${call.method} is not implemented!");
  //   }
  // });

  // Tell the native side to start the background isolate.
  // Airship._backgroundChannel.invokeMethod<void>("backgroundIsolateStarted");
}

typedef BackgroundMessageHandler = Future<void> Function(
    Map<String, dynamic> payload, Notification? notification);

