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
}
