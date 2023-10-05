import 'push_payload.dart';
import 'push_notification_status.dart';
import 'ios_push_options.dart';
import 'airship_utils.dart';

/// Event fired when the iOS authorized settings change.
class IOSAuthorizedNotificationSettingsChangedEvent {
  // The authorized settings
  final List<IOSAuthorizedNotificationSetting> authorizedSettings;

  const IOSAuthorizedNotificationSettingsChangedEvent._internal(this.authorizedSettings);

  static IOSAuthorizedNotificationSettingsChangedEvent fromJson(dynamic json) {
    var authorizedSettings = List<String>.from(json["authorizedSettings"]);

    return IOSAuthorizedNotificationSettingsChangedEvent._internal(
        AirshipUtils.parseIOSAuthorizedSettings(authorizedSettings)
    );
  }

  @override
  String toString() {
    return "IOSAuthorizedNotificationSettingsChangedEvent(authorizedSettings=$authorizedSettings)";
  }
}

/// Event fired when the message center should be displayed.
class DisplayMessageCenterEvent {
  // The optional message Id
  final String? messageId;

  const DisplayMessageCenterEvent._internal(this.messageId);

  static DisplayMessageCenterEvent fromJson(dynamic json) {
    var messageId = json["messageId"];
    return DisplayMessageCenterEvent._internal(messageId);
  }

  @override
  String toString() {
    return "DisplayMessageCenterEvent(messageId=$messageId)";
  }
}


/// Event fired when the message center updates.
class MessageCenterUpdatedEvent {
  
  /// Unread count
  final int messageUnreadCount;

  /// Message count
  final int messageCount;

  const MessageCenterUpdatedEvent._internal(this.messageUnreadCount, this.messageCount);

  static MessageCenterUpdatedEvent fromJson(dynamic json) {
    var messageUnreadCount = json["messageUnreadCount"];
    var messageCount = json["messageCount"];
    return MessageCenterUpdatedEvent._internal(messageUnreadCount, messageCount);
  }

  @override
  String toString() {
    return "MessageCenterUpdatedEvent(messageUnreadCount=$messageUnreadCount, messageCount=$messageCount)";
  }
}

/// Event fired when a channel is created.
class ChannelCreatedEvent {
  /// The channel ID.
  final String channelId;

  const ChannelCreatedEvent._internal(this.channelId);

  static ChannelCreatedEvent fromJson(dynamic json) {
    var channelId = json["channelId"] as String;
    return ChannelCreatedEvent._internal(channelId);
  }

  @override
  String toString() {
    return "ChannelCreatedEvent(channelId=$channelId)";
  }
}

/// Event fired when a push token is received by Airship.
class PushTokenReceivedEvent {
  /// The push token.
  final String pushToken;

  const PushTokenReceivedEvent._internal(this.pushToken);

  static PushTokenReceivedEvent fromJson(dynamic json) {
    var pushToken = json["pushToken"] as String;
    return PushTokenReceivedEvent._internal(pushToken);
  }

  @override
  String toString() {
    return "PushTokenReceivedEvent(pushToken=$pushToken)";
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
  final bool isForeground;

  /// The push [PushPayload].
  final PushPayload pushPayload;

  const NotificationResponseEvent._internal(
      this.actionId, this.isForeground, this.pushPayload);

  static NotificationResponseEvent fromJson(dynamic json) {
    var actionId = json["actionId"];
    var isForeground = json["isForeground"];
    var pushPayload = PushPayload.fromJson(json["pushPayload"]);

    return NotificationResponseEvent._internal(
        actionId, isForeground, pushPayload);
  }

  @override
  String toString() {
    return "NotificationResponseEvent(actionId=$actionId, isForeground=$isForeground, pushPayload=$pushPayload)";
  }
}

/// Event fired when a push is received.
class PushReceivedEvent {
  // The push payload
  final PushPayload pushPayload;

  const PushReceivedEvent._internal(this.pushPayload);

  static PushReceivedEvent fromJson(dynamic json) {
    var pushPayload = PushPayload.fromJson(json["pushPayload"]);
    return PushReceivedEvent._internal(pushPayload);
  }

  @override
  String toString() {
    return "PushReceivedEvent(pushPayload=$pushPayload)";
  }
}