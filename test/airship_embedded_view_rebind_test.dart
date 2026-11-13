import 'package:airship_flutter/airship_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Flutter reuses the state when an [AirshipEmbeddedView] is rebuilt in the
/// same position, so the view has to rebind when the ID it tracks changes.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const StandardMethodCodec codec = StandardMethodCodec();
  const String eventChannelName =
      'com.airship.flutter/event/pending_embedded_updated';
  const MethodChannel mainChannel =
      MethodChannel('com.airship.flutter/airship');

  final binaryMessenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() {
    binaryMessenger.setMockMethodCallHandler(
      mainChannel,
      (MethodCall call) async => null,
    );
    // An EventChannel negotiates listen/cancel over a method channel.
    binaryMessenger.setMockMethodCallHandler(
      const MethodChannel(eventChannelName, codec),
      (MethodCall call) async => null,
    );
    binaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform_views,
      (MethodCall call) async => call.method == 'create' ? 0 : null,
    );
  });

  tearDown(() {
    binaryMessenger.setMockMethodCallHandler(mainChannel, null);
    binaryMessenger.setMockMethodCallHandler(
        const MethodChannel(eventChannelName, codec), null);
    binaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform_views, null);
  });

  Future<void> emitAvailable(List<String> embeddedIds) {
    return binaryMessenger.handlePlatformMessage(
      eventChannelName,
      codec.encodeSuccessEnvelope({
        'pending': [
          for (final id in embeddedIds)
            {
              'embeddedId': id,
              'instanceId': '$id-instance',
              'priority': 0,
              'extras': <String, Object?>{},
            }
        ],
      }),
      (ByteData? _) {},
    );
  }

  // Airship.inApp is a lazily created singleton that subscribes to the event
  // channel when it is first touched, and its cached state outlives each test.
  // Touching it here keeps the tests independent of the order they run in.
  setUp(() async {
    Airship.inApp.isEmbeddedAvailable(embeddedId: 'warm-up');
    await emitAvailable(<String>[]);
  });

  /// The platform override has to be cleared before the body returns, or the
  /// test framework reports it as leaked foundation state.
  Future<void> onAndroid(Future<void> Function() body) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    try {
      await body();
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  }

  Widget host(String embeddedId) => MaterialApp(
        home: Center(
          child: SizedBox(
            width: 300,
            height: 200,
            child: AirshipEmbeddedView(embeddedId: embeddedId),
          ),
        ),
      );

  /// The view renders a keyed box for each availability state.
  final available = find.byKey(const ValueKey<bool>(true));
  final unavailable = find.byKey(const ValueKey<bool>(false));

  testWidgets('shows content once its embedded ID becomes available',
      (WidgetTester tester) async {
    await onAndroid(() async {
      await emitAvailable(<String>['slot-a']);
      await tester.pumpWidget(host('slot-a'));
      await tester.pumpAndSettle();

      expect(available, findsOneWidget);
    });
  });

  testWidgets('collapses when rebuilt with an ID that has no content',
      (WidgetTester tester) async {
    await onAndroid(() async {
      await emitAvailable(<String>['slot-a']);
      await tester.pumpWidget(host('slot-a'));
      await tester.pumpAndSettle();
      expect(available, findsOneWidget);

      // Same position and no key, so the state is reused, not recreated.
      await tester.pumpWidget(host('slot-b'));
      await tester.pumpAndSettle();

      expect(unavailable, findsOneWidget,
          reason: 'availability must follow the new embedded ID');
    });
  });

  testWidgets('picks up content for an ID supplied after the first build',
      (WidgetTester tester) async {
    await onAndroid(() async {
      await emitAvailable(<String>['slot-a']);
      await tester.pumpWidget(host('slot-a'));
      await tester.pumpAndSettle();

      await emitAvailable(<String>['slot-a', 'slot-b']);
      await tester.pumpWidget(host('slot-b'));
      await tester.pumpAndSettle();

      expect(available, findsOneWidget);
    });
  });
}
