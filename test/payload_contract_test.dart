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
      final status = PushNotificationStatusChangedEvent.fromJson(
              payload('notification_status_changed'))
          .status;
      // The parser defaults a missing key to false, so a field read from the
      // wrong key only shows up if the fixture has it set to true.
      expect(status.isUserNotificationsEnabled, isTrue);
      expect(status.areNotificationsAllowed, isTrue);
      expect(status.isPushPrivacyFeatureEnabled, isTrue);
      expect(status.isPushTokenRegistered, isTrue);
      expect(status.isOptedIn, isTrue);
      expect(status.isUserOptedIn, isTrue);
      expect(status.notificationPermissionStatus, PermissionStatus.granted);
    });

    test('notification_status_changed reads each field from its own key', () {
      // With every field true, two fields reading each other's key still pass.
      // Setting one at a time shows which getter each key feeds.
      final getters = <String, bool Function(PushNotificationStatus)>{
        'isUserNotificationsEnabled': (s) => s.isUserNotificationsEnabled,
        'areNotificationsAllowed': (s) => s.areNotificationsAllowed,
        'isPushPrivacyFeatureEnabled': (s) => s.isPushPrivacyFeatureEnabled,
        'isPushTokenRegistered': (s) => s.isPushTokenRegistered,
        'isOptedIn': (s) => s.isOptedIn,
        'isUserOptedIn': (s) => s.isUserOptedIn,
      };

      getters.forEach((key, _) {
        final status = PushNotificationStatus.fromJson(<String, dynamic>{
          for (final name in getters.keys) name: name == key,
        });
        getters.forEach((name, getter) {
          expect(getter(status), name == key,
              reason: 'only $key was set, but $name read ${getter(status)}');
        });
      });
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

    test('override_presentation_options carries a parseable push payload', () {
      // The push handlers read this inline rather than through an event class.
      final body = payload('override_presentation_options');
      expect(PushPayload.fromJson(body['pushPayload']).alert,
          'Flash sale ends tonight');
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

  group('event channel fixtures', () {
    // A listener passed a constant or variable would be invisible to the
    // literal match below, so the number of call sites is checked against the
    // number of literals found. Raw counts, not the de-duplicated set:
    // override_presentation_options is listened to from two places.
    final sources = Directory('${root.path}/lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .map((file) => file.readAsStringSync())
        .toList();

    final callSites = sources
        .map((source) => RegExp(r'\.getEventStream\(').allMatches(source).length)
        .fold<int>(0, (total, count) => total + count);

    final literalChannels = sources
        .expand((source) =>
            RegExp('''\\.getEventStream\\(\\s*['"]([^'"]+)['"]''')
                .allMatches(source)
                .map((match) => match.group(1)!))
        .toList();

    test('every listener names its channel with a string literal', () {
      expect(literalChannels, isNotEmpty,
          reason: 'The channel extraction matched nothing');
      expect(literalChannels.length, callSites,
          reason: 'getEventStream called with a non-literal channel name');
    });

    test('every channel the Dart layer listens to has a fixture', () {
      final missing = literalChannels
          .toSet()
          .map((channel) => channel.split('/').last)
          .where((name) => !File('${fixtures.path}/$name.json').existsSync())
          .toList()
        ..sort();

      expect(missing, isEmpty,
          reason: 'Event channels with no payload fixture: $missing');
    });
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
