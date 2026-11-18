import 'dart:async';

import 'package:airship_flutter/airship_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Flutter reuses the state when an [AirshipEmbeddedView] is rebuilt in the
/// same position, so the view has to rebind to whatever it is now pointed at.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const StandardMethodCodec codec = StandardMethodCodec();
  const String eventChannelName =
      'com.airship.flutter/event/pending_embedded_updated';
  const MethodChannel mainChannel =
      MethodChannel('com.airship.flutter/airship');

  final binaryMessenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  // Every call the framework makes to create or dispose a platform view.
  final List<MethodCall> viewCalls = <MethodCall>[];

  // When set, the next platform view creation does not finish until it
  // completes, which holds the window between a rebind and the new view.
  Completer<void>? holdNextCreate;

  setUp(() {
    viewCalls.clear();
    holdNextCreate = null;

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
      (MethodCall call) async {
        viewCalls.add(call);
        switch (call.method) {
          case 'create':
            final Completer<void>? hold = holdNextCreate;
            holdNextCreate = null;
            await hold?.future;
            return 0;
          case 'resize':
            // The texture controller asserts it gets the applied size back.
            final Map<Object?, Object?> args = call.arguments as Map;
            return <Object?, Object?>{
              'width': args['width'],
              'height': args['height'],
            };
          default:
            return null;
        }
      },
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

  /// Emits from outside the test's fake async zone, which is where the stream
  /// behind [Airship.inApp] was created. Without this an event sent after the
  /// widget is pumped never reaches it.
  Future<void> emit(WidgetTester tester, List<String> embeddedIds) async {
    await tester.runAsync(() => emitAvailable(embeddedIds));
    await tester.pumpAndSettle();
  }

  Future<void> reportHeight(WidgetTester tester, int viewId, double height) async {
    await binaryMessenger.handlePlatformMessage(
      'com.airship.flutter/EmbeddedView_$viewId',
      codec.encodeMethodCall(
          MethodCall('onSizeUpdate', <String, Object?>{'height': height})),
      (ByteData? _) {},
    );
    await tester.pumpAndSettle();
  }

  List<int> createdViews() => viewCalls
      .where((call) => call.method == 'create')
      .map((call) => (call.arguments as Map)['id'] as int)
      .toList();

  int disposedViews() =>
      viewCalls.where((call) => call.method == 'dispose').length;

  Widget host(String embeddedId, {AirshipEmbeddedViewSelection? selection}) =>
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 300,
            height: 200,
            child: AirshipEmbeddedView(
              embeddedId: embeddedId,
              selection: selection,
            ),
          ),
        ),
      );

  // A parent that leaves the height unbounded, so the view takes the height
  // the native side reports.
  Widget scrollingHost(String embeddedId,
          {AirshipEmbeddedViewSelection? selection}) =>
      MaterialApp(
        home: SingleChildScrollView(
          child: AirshipEmbeddedView(
            embeddedId: embeddedId,
            selection: selection,
          ),
        ),
      );

  /// The view renders a keyed box for each availability state.
  final available = find.byKey(const ValueKey<bool>(true));
  final unavailable = find.byKey(const ValueKey<bool>(false));

  const AirshipEmbeddedViewSelection instanceOne =
      AirshipEmbeddedViewSelectionInstanceId('slot-a-instance');
  const AirshipEmbeddedViewSelection instanceTwo =
      AirshipEmbeddedViewSelectionInstanceId('slot-a-other');

  group('availability', () {
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

    testWidgets('shows content that arrives for the new ID after the rebind',
        (WidgetTester tester) async {
      await onAndroid(() async {
        // Neither slot has content, so the only way the view can end up
        // showing slot-b is by listening for slot-b.
        await tester.pumpWidget(host('slot-a'));
        await tester.pumpAndSettle();
        await tester.pumpWidget(host('slot-b'));
        await tester.pumpAndSettle();
        expect(unavailable, findsOneWidget);

        await emit(tester, <String>['slot-b']);

        expect(available, findsOneWidget);
      });
    });
  });

  group('native view', () {
    testWidgets('is recreated when the embedded ID changes',
        (WidgetTester tester) async {
      await onAndroid(() async {
        await emitAvailable(<String>['slot-a', 'slot-b']);
        await tester.pumpWidget(host('slot-a'));
        await tester.pumpAndSettle();
        expect(createdViews(), hasLength(1));

        await tester.pumpWidget(host('slot-b'));
        await tester.pumpAndSettle();

        expect(createdViews(), hasLength(2),
            reason: 'creation params are only read when the view is created');
        expect(disposedViews(), 1);
      });
    });

    testWidgets('is recreated when only the selection changes',
        (WidgetTester tester) async {
      await onAndroid(() async {
        await emitAvailable(<String>['slot-a']);
        await tester.pumpWidget(host('slot-a', selection: instanceOne));
        await tester.pumpAndSettle();

        await tester.pumpWidget(host('slot-a', selection: instanceTwo));
        await tester.pumpAndSettle();

        expect(createdViews(), hasLength(2));
        expect(disposedViews(), 1);
      });
    });

    testWidgets('is kept when the widget is rebuilt with the same inputs',
        (WidgetTester tester) async {
      await onAndroid(() async {
        await emitAvailable(<String>['slot-a']);
        await tester.pumpWidget(host('slot-a', selection: instanceOne));
        await tester.pumpAndSettle();

        await tester.pumpWidget(host('slot-a', selection: instanceOne));
        await tester.pumpAndSettle();

        expect(createdViews(), hasLength(1));
        expect(disposedViews(), 0);
      });
    });

    testWidgets('is kept when no selection becomes the priority selection',
        (WidgetTester tester) async {
      // Native treats a missing selection as priority, so these show the same
      // content and there is nothing to recreate.
      await onAndroid(() async {
        await emitAvailable(<String>['slot-a']);
        await tester.pumpWidget(host('slot-a'));
        await tester.pumpAndSettle();

        await tester.pumpWidget(
            host('slot-a', selection: const AirshipEmbeddedViewSelectionPriority()));
        await tester.pumpAndSettle();

        expect(createdViews(), hasLength(1));
        expect(disposedViews(), 0);
      });
    });
  });

  group('measured height', () {
    double fallbackHeight(WidgetTester tester) =>
        tester.view.physicalSize.height / tester.view.devicePixelRatio;

    double shownHeight(WidgetTester tester) => tester.getSize(available).height;

    testWidgets('is dropped when the embedded ID changes',
        (WidgetTester tester) async {
      await onAndroid(() async {
        await emitAvailable(<String>['slot-a', 'slot-b']);
        await tester.pumpWidget(scrollingHost('slot-a'));
        await tester.pumpAndSettle();
        await reportHeight(tester, createdViews().single, 250);
        expect(shownHeight(tester), 250);

        await tester.pumpWidget(scrollingHost('slot-b'));
        await tester.pumpAndSettle();

        expect(shownHeight(tester), fallbackHeight(tester));
      });
    });

    testWidgets('is dropped when only the selection changes',
        (WidgetTester tester) async {
      await onAndroid(() async {
        await emitAvailable(<String>['slot-a']);
        await tester
            .pumpWidget(scrollingHost('slot-a', selection: instanceOne));
        await tester.pumpAndSettle();
        await reportHeight(tester, createdViews().single, 250);
        expect(shownHeight(tester), 250);

        await tester
            .pumpWidget(scrollingHost('slot-a', selection: instanceTwo));
        await tester.pumpAndSettle();

        expect(shownHeight(tester), fallbackHeight(tester),
            reason: 'the previous instance height must not size the new one');
      });
    });

    testWidgets('ignores a late report from the view that was replaced',
        (WidgetTester tester) async {
      await onAndroid(() async {
        await emitAvailable(<String>['slot-a', 'slot-b']);
        await tester.pumpWidget(scrollingHost('slot-a'));
        await tester.pumpAndSettle();
        final int replacedView = createdViews().single;

        // Hold the new view's creation open: until it finishes, the replaced
        // view's channel is the only one the widget has.
        final Completer<void> creation = Completer<void>();
        holdNextCreate = creation;
        await tester.pumpWidget(scrollingHost('slot-b'));
        await tester.pump();
        final int currentView = createdViews().last;
        expect(currentView, isNot(replacedView));

        await reportHeight(tester, replacedView, 400);
        expect(shownHeight(tester), fallbackHeight(tester),
            reason: 'the replaced view must no longer be heard');

        creation.complete();
        await tester.pumpAndSettle();
        await reportHeight(tester, currentView, 300);
        expect(shownHeight(tester), 300);
      });
    });
  });
}
