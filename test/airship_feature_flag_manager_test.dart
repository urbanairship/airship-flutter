import 'dart:convert';

import 'package:airship_flutter/airship_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('com.airship.flutter/airship');

  final List<MethodCall> calls = <MethodCall>[];

  /// Mocks the platform side, recording every call and replying with
  /// [response], or throwing [error] if one is set.
  void mockChannel({Object? response, PlatformException? error}) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      calls.add(call);
      if (error != null) {
        throw error;
      }
      return response;
    });
  }

  final Map<String, Object?> flagJson = {
    "isEligible": true,
    "exists": true,
    "variables": {"foo": "bar"},
    "_internal": {"name": "rad_flag"},
  };

  setUp(() {
    calls.clear();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('flag', () {
    test('uses the result cache by default', () async {
      mockChannel(response: flagJson);

      await Airship.featureFlagManager.flag("rad_flag");

      expect(calls, hasLength(1));
      expect(calls.first.method, "featureFlagManager#flag");
      expect(calls.first.arguments, {
        "flagName": "rad_flag",
        "useResultCache": true,
      });
    });

    test('passes useResultCache through', () async {
      mockChannel(response: flagJson);

      await Airship.featureFlagManager.flag("rad_flag", useResultCache: false);

      expect(calls.first.arguments, {
        "flagName": "rad_flag",
        "useResultCache": false,
      });
    });

    test('parses the platform response', () async {
      mockChannel(response: flagJson);

      final flag = await Airship.featureFlagManager.flag("rad_flag");

      expect(flag.isEligible, true);
      expect(flag.exists, true);
      expect(flag.variables, {"foo": "bar"});
      expect(flag.original, {"name": "rad_flag"});
    });

    test('throws instead of returning null on a platform error', () async {
      mockChannel(
        error: PlatformException(code: "AIRSHIP_ERROR", message: "boom"),
      );

      expect(
        Airship.featureFlagManager.flag("rad_flag"),
        throwsA(isA<PlatformException>()),
      );
    });

    test('throws when the platform has no implementation', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);

      expect(
        Airship.featureFlagManager.flag("rad_flag"),
        throwsA(isA<MissingPluginException>()),
      );
    });

    test('throws when the platform returns nothing', () async {
      mockChannel(response: null);

      expect(
        Airship.featureFlagManager.flag("rad_flag"),
        throwsA(isA<PlatformException>()),
      );
    });
  });

  group('trackInteraction', () {
    test('sends the flag as a json string', () async {
      mockChannel(response: flagJson);
      final flag = await Airship.featureFlagManager.flag("rad_flag");
      calls.clear();

      await Airship.featureFlagManager.trackInteraction(flag);

      expect(calls, hasLength(1));
      expect(calls.first.method, "featureFlagManager#trackInteraction");
      expect(jsonDecode(calls.first.arguments as String), flagJson);
    });
  });

  group('result cache', () {
    test('getFlagFromResultCache sends the flag name', () async {
      mockChannel(response: flagJson);

      final flag =
          await Airship.featureFlagManager.getFlagFromResultCache("rad_flag");

      expect(calls, hasLength(1));
      expect(calls.first.method, "featureFlagManager#resultCacheGetFlag");
      expect(calls.first.arguments, "rad_flag");
      expect(flag?.isEligible, true);
    });

    test('getFlagFromResultCache returns null on a cache miss', () async {
      mockChannel(response: null);

      final flag =
          await Airship.featureFlagManager.getFlagFromResultCache("rad_flag");

      expect(calls.first.method, "featureFlagManager#resultCacheGetFlag");
      expect(flag, isNull);
    });

    test('setFlagInResultCache sends the flag json and a ttl in ms', () async {
      mockChannel(response: flagJson);
      final flag = await Airship.featureFlagManager.flag("rad_flag");
      calls.clear();

      await Airship.featureFlagManager
          .setFlagInResultCache(flag, const Duration(seconds: 30));

      expect(calls, hasLength(1));
      expect(calls.first.method, "featureFlagManager#resultCacheSetFlag");
      final arguments = calls.first.arguments as Map;
      expect(arguments["ttl"], 30000);
      expect(jsonDecode(arguments["flag"] as String), flagJson);
    });

    test('removeFlagFromResultCache sends the flag name', () async {
      mockChannel(response: null);

      await Airship.featureFlagManager.removeFlagFromResultCache("rad_flag");

      expect(calls, hasLength(1));
      expect(calls.first.method, "featureFlagManager#resultCacheRemoveFlag");
      expect(calls.first.arguments, "rad_flag");
    });
  });

  group('status', () {
    test('parses up_to_date', () async {
      mockChannel(response: "up_to_date");

      final status = await Airship.featureFlagManager.status();

      expect(calls, hasLength(1));
      expect(calls.first.method, "featureFlagManager#status");
      expect(status, FeatureFlagStatus.upToDate);
    });

    test('parses stale', () async {
      mockChannel(response: "stale");

      final status = await Airship.featureFlagManager.status();

      expect(status, FeatureFlagStatus.stale);
    });

    test('parses out_of_date', () async {
      mockChannel(response: "out_of_date");

      final status = await Airship.featureFlagManager.status();

      expect(status, FeatureFlagStatus.outOfDate);
    });
  });

  group('waitRefresh', () {
    test('sends maxTimeMillis when provided', () async {
      mockChannel(response: null);

      await Airship.featureFlagManager
          .waitRefresh(maxTime: const Duration(seconds: 10));

      expect(calls, hasLength(1));
      expect(calls.first.method, "featureFlagManager#waitRefresh");
      expect(calls.first.arguments, {"maxTimeMillis": 10000});
    });

    test('omits maxTimeMillis when not provided', () async {
      mockChannel(response: null);

      await Airship.featureFlagManager.waitRefresh();

      expect(calls.first.arguments, <String, Object?>{});
    });
  });

  group('statusUpdates', () {
    const String eventChannelName =
        "com.airship.flutter/event/feature_flag_status_changed";
    const StandardMethodCodec codec = StandardMethodCodec();

    setUp(() {
      // An EventChannel negotiates listen/cancel over a method channel.
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel(eventChannelName, codec),
        (MethodCall call) async => null,
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
              const MethodChannel(eventChannelName, codec), null);
    });

    Future<void> emit(Object? event) {
      return TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
        eventChannelName,
        codec.encodeSuccessEnvelope(event),
        (ByteData? _) {},
      );
    }

    test('parses the status out of the event body', () async {
      final Future<FeatureFlagStatusChangedEvent> event =
          Airship.featureFlagManager.statusUpdates.first;
      await Future<void>.delayed(Duration.zero);

      await emit({"status": "stale"});

      expect((await event).status, FeatureFlagStatus.stale);
    });

    test('surfaces an unrecognized status instead of reporting out of date',
        () async {
      // The expectation has to be attached before the event is emitted, or the
      // error completes a future nobody is listening to and escapes the zone.
      final Future<void> expectation = expectLater(
        Airship.featureFlagManager.statusUpdates.first,
        throwsArgumentError,
      );
      await Future<void>.delayed(Duration.zero);

      await emit({"status": "not_a_real_status"});

      await expectation;
    });
  });
}
