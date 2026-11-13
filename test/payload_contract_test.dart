import 'dart:convert';
import 'dart:io';

import 'package:airship_flutter/airship_flutter.dart';
import 'package:airship_flutter/src/airship_utils.dart';
import 'package:flutter_test/flutter_test.dart';

/// Asserts the Dart parsers accept the payloads the native plugins send.
///
/// Nothing else compares the two sides, so a key or enum spelling that only one
/// side knows about still passes every other test. The fixtures under
/// `test/fixtures/events` are the payload shapes, one per event channel, and
/// every channel the Dart layer listens to has to have one.
void main() {
  final Directory root = _packageRoot();
  final Directory fixtures = Directory('${root.path}/test/fixtures/events');

  Map<String, dynamic> payload(String name) {
    final file = File('${fixtures.path}/$name.json');
    if (!file.existsSync()) {
      throw StateError('Missing payload fixture: $name.json');
    }
    return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  }

  group('event payloads parse', () {
    test('channel_created', () {
      final event = ChannelCreatedEvent.fromJson(payload('channel_created'));
      expect(event.channelId, '9c36e8c7-5a73-4f0b-8f1a-4a2a0f4a1b2c');
    });

    test('push_token_received', () {
      final event =
          PushTokenReceivedEvent.fromJson(payload('push_token_received'));
      expect(event.pushToken, isNotEmpty);
    });

    test('deep_link_received', () {
      final event = DeepLinkEvent.fromJson(payload('deep_link_received'));
      expect(event.deepLink, 'example://home/offers?id=42');
    });

    test('display_message_center', () {
      final event =
          DisplayMessageCenterEvent.fromJson(payload('display_message_center'));
      expect(event.messageId, 'Ck1lc3NhZ2VJZA');
    });

    test('display_message_center without a message id', () {
      final event = DisplayMessageCenterEvent.fromJson(
          <String, dynamic>{'messageId': null});
      expect(event.messageId, isNull);
    });

    test('display_preference_center', () {
      final event = DisplayPreferenceCenterEvent.fromJson(
          payload('display_preference_center'));
      expect(event.preferenceCenterId, 'neat-preference-center');
    });

    test('message_center_updated', () {
      final event =
          MessageCenterUpdatedEvent.fromJson(payload('message_center_updated'));
      expect(event.messageUnreadCount, 3);
      expect(event.messageCount, 10);
    });

    test('ios_authorized_notification_settings_changed', () {
      final event = IOSAuthorizedNotificationSettingsChangedEvent.fromJson(
          payload('ios_authorized_notification_settings_changed'));
      // Every spelling in the fixture has to map, or the list comes back short.
      expect(event.authorizedSettings,
          hasLength(IOSAuthorizedNotificationSetting.values.length));
    });

    test('pending_embedded_updated', () {
      final event = EmbeddedInfoUpdatedEvent.fromJson(
          payload('pending_embedded_updated'));
      expect(event.embeddedInfos, hasLength(1));
      expect(event.embeddedInfos.single.embeddedId, 'home-banner');
      expect(event.embeddedInfos.single.extras['campaign'], 'fall-sale');
    });

    test('pending_embedded_updated with a priority sent as a double', () {
      // Priorities cross the channel as a double on at least one platform.
      final event = EmbeddedInfoUpdatedEvent.fromJson(<String, dynamic>{
        'pending': [
          {
            'embeddedId': 'home-banner',
            'instanceId': 'id',
            'priority': 2.0,
            'extras': <String, dynamic>{},
          }
        ],
      });
      expect(event.embeddedInfos.single.priority, 2);
    });

    test('notification_status_changed', () {
      final event = PushNotificationStatusChangedEvent.fromJson(
          payload('notification_status_changed'));
      expect(event.status.isOptedIn, isTrue);
      expect(event.status.notificationPermissionStatus,
          PermissionStatus.granted);
    });

    test('push_received', () {
      final event = PushReceivedEvent.fromJson(payload('push_received'));
      expect(event.pushPayload.alert, 'Your order has shipped');
      expect(event.pushPayload.title, 'On its way');
      expect(event.pushPayload.extras['order_id'], '42');
    });

    test('notification_response', () {
      final event =
          NotificationResponseEvent.fromJson(payload('notification_response'));
      expect(event.actionId, 'view_order');
      expect(event.isForeground, isTrue);
      expect(event.pushPayload.notificationId, isNotNull);
    });

    test('override_presentation_options', () {
      // Read inline by the push handlers rather than through an event class,
      // so the two fields they reach for are what this pins down.
      final body = payload('override_presentation_options');
      expect(body['requestId'], isA<String>());
      expect(PushPayload.fromJson(body['pushPayload']).alert,
          'Flash sale ends tonight');
    });

    test('feature_flag_status_changed', () {
      // The event class is library private; the stream that exposes it is
      // covered in airship_feature_flag_manager_test. This pins the shape.
      expect(payload('feature_flag_status_changed')['status'], 'stale');
    });
  });

  group('enum spellings the native side sends', () {
    test('every Feature has a spelling that round-trips', () {
      for (final feature in Feature.values) {
        final spelling = AirshipUtils.toFeatureStringList(<Feature>[feature]);
        expect(spelling, hasLength(1),
            reason: '$feature has no native spelling');
        expect(AirshipUtils.parseFeatures(spelling), <Feature>[feature]);
      }
    });

    test('every ChannelScope round-trips', () {
      for (final scope in ChannelScope.values) {
        final spelling = AirshipUtils.toChannelScopeString(scope);
        expect(AirshipUtils.parseChannelScope(spelling), scope);
      }
    });

    test('every IOSAuthorizedNotificationStatus spelling is understood', () {
      const spellings = <String, IOSAuthorizedNotificationStatus>{
        'not_determined': IOSAuthorizedNotificationStatus.notDetermined,
        'denied': IOSAuthorizedNotificationStatus.denied,
        'authorized': IOSAuthorizedNotificationStatus.authorized,
        'provisional': IOSAuthorizedNotificationStatus.provisional,
        'ephemeral': IOSAuthorizedNotificationStatus.ephemeral,
      };
      // A status missing here would be parsed as notDetermined and look like a
      // user who never answered the prompt.
      expect(spellings, hasLength(IOSAuthorizedNotificationStatus.values.length));
      spellings.forEach((spelling, expected) {
        expect(AirshipUtils.parseIOSAuthorizedStatus(spelling), expected);
      });
    });

    test('an unrecognised feature is skipped rather than thrown', () {
      expect(AirshipUtils.parseFeatures(<String>['not_a_feature']), isEmpty);
    });
  });

  test('every event channel the Dart layer listens to has a fixture', () {
    final listened = Directory('${root.path}/lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .expand((file) =>
            RegExp('''getEventStream\\(\\s*['"]([^'"]+)['"]''')
                .allMatches(file.readAsStringSync())
                .map((match) => match.group(1)!))
        .toSet();

    final missing = listened
        .map((channel) => channel.split('/').last)
        .where((name) => !File('${fixtures.path}/$name.json').existsSync())
        .toList()
      ..sort();

    expect(missing, isEmpty,
        reason: 'Event channels with no payload fixture: $missing');
  });
}

/// Walks up from the current directory to find the plugin root.
Directory _packageRoot() {
  Directory directory = Directory.current;
  while (true) {
    final pubspec = File('${directory.path}/pubspec.yaml');
    if (pubspec.existsSync() &&
        pubspec.readAsStringSync().contains('name: airship_flutter')) {
      return directory;
    }

    final parent = directory.parent;
    if (parent.path == directory.path) {
      throw StateError('Unable to find the airship_flutter package root');
    }
    directory = parent;
  }
}
