import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Verifies that the Dart layer and both native plugins agree on the method and
/// event channel names they exchange. Dart level tests mock the platform, so a
/// name that exists on only one side passes everywhere else. This checks both
/// directions: a method Dart calls that nothing handles, and a method or event
/// a platform handles that Dart never reaches.
void main() {
  final Directory root = _packageRoot();

  // The per-view and background plugins own channels of their own, so a scan of
  // the main plugin alone would report their methods as unhandled.
  final Set<String> iosMethods = _nativeNames(
    root,
    const <String>[
      'ios/airship_flutter/Sources/airship_flutter/AirshipPlugin.swift',
      'ios/airship_flutter/Sources/airship_flutter/AirshipEmbeddedView.swift',
      'ios/airship_flutter/Sources/airship_flutter/AirshipInboxMessageView.swift',
    ],
    RegExp(r'case\s+"([^"]+)"'),
  );

  final Set<String> androidMethods = _nativeNames(
    root,
    const <String>[
      'android/src/main/kotlin/com/airship/flutter/AirshipPlugin.kt',
      'android/src/main/kotlin/com/airship/flutter/FlutterEmbeddedView.kt',
      'android/src/main/kotlin/com/airship/flutter/FlutterInboxMessageView.kt',
      'android/src/main/kotlin/com/airship/flutter/AirshipBackgroundExecutor.kt',
    ],
    RegExp(r'"([^"]+)"\s*->'),
  );

  // Two shapes: a literal at the invoke site, which is the only way names
  // without a `#` appear, and a bare `module#method` literal, which is how the
  // editors pass their method name to a constructor instead of calling it.
  final Set<String> dartMethods = <String>{
    ..._dartMatches(
      root,
      RegExp('''invokeM[A-Za-z]*(?:<[^>]*>)?\\(\\s*['"]([^'"]+)['"]'''),
    ),
    ..._dartMatches(
      root,
      RegExp('''['"]([A-Za-z][A-Za-z0-9]*(?:#[A-Za-z][A-Za-z0-9]*)+)['"]'''),
    ),
  };

  final Set<String> dartEvents = _dartMatches(
    root,
    RegExp('''getEventStream\\(\\s*['"]([^'"]+)['"]'''),
  );

  final Set<String> iosEvents = _nativeNames(
    root,
    const <String>[
      'ios/airship_flutter/Sources/airship_flutter/AirshipPlugin.swift'
    ],
    _eventChannelPattern,
  );

  final Set<String> androidEvents = _nativeNames(
    root,
    const <String>[
      'android/src/main/kotlin/com/airship/flutter/AirshipPlugin.kt'
    ],
    _eventChannelPattern,
  );

  // Methods that exist on one platform only. Platform specific APIs are
  // normally named with an `#ios#` or `#android#` segment; these are the
  // exceptions.
  const Set<String> iosOnlyMethods = {
    'liveActivity#list',
    'liveActivity#listAll',
    'liveActivity#start',
    'liveActivity#stop',
    'liveActivity#update',
  };
  const Set<String> androidOnlyMethods = {
    'liveUpdate#clearAll',
    // Acknowledges the isolate the Android background handler runs in. iOS has
    // no equivalent, and accepts startBackgroundIsolate as a no-op.
    'backgroundIsolateStarted',
  };

  // Emitted natively with nothing listening in Dart. MOBILE-6037 decides
  // whether this becomes API or is removed.
  const Set<String> unconsumedEvents = {
    'com.airship.flutter/event/background_push_received',
  };

  test('the extraction finds names on every side', () {
    // Guards against a regex that silently matches nothing.
    expect(dartMethods.length, greaterThan(50));
    expect(iosMethods, isNotEmpty);
    expect(androidMethods, isNotEmpty);
    expect(dartEvents, isNotEmpty);
    expect(iosEvents, isNotEmpty);
    expect(androidEvents, isNotEmpty);
  });

  group('methods Dart calls', () {
    test('are handled on iOS', () {
      final missing = dartMethods
          .where((method) => !method.contains('#android#'))
          .where((method) => !androidOnlyMethods.contains(method))
          .where((method) => !iosMethods.contains(method))
          .toList()
        ..sort();

      expect(missing, isEmpty, reason: 'Missing iOS implementations: $missing');
    });

    test('are handled on Android', () {
      final missing = dartMethods
          .where((method) => !method.contains('#ios#'))
          .where((method) => !iosOnlyMethods.contains(method))
          .where((method) => !androidMethods.contains(method))
          .toList()
        ..sort();

      expect(missing, isEmpty,
          reason: 'Missing Android implementations: $missing');
    });
  });

  group('methods the native plugins handle', () {
    test('are reachable from Dart on iOS', () {
      final unreachable =
          iosMethods.where((method) => !dartMethods.contains(method)).toList()
            ..sort();

      expect(unreachable, isEmpty,
          reason: 'Handled on iOS with no Dart binding: $unreachable');
    });

    test('are reachable from Dart on Android', () {
      final unreachable = androidMethods
          .where((method) => !dartMethods.contains(method))
          .toList()
        ..sort();

      expect(unreachable, isEmpty,
          reason: 'Handled on Android with no Dart binding: $unreachable');
    });
  });

  group('event channels', () {
    test('Dart listens only to channels a platform emits', () {
      final emitted = <String>{...iosEvents, ...androidEvents};
      final orphaned =
          dartEvents.where((event) => !emitted.contains(event)).toList()
            ..sort();

      expect(orphaned, isEmpty,
          reason: 'Listened to in Dart but never emitted: $orphaned');
    });

    test('every channel a platform emits has a Dart listener', () {
      final emitted = <String>{...iosEvents, ...androidEvents};
      final unconsumed = emitted
          .where((event) => !dartEvents.contains(event))
          .where((event) => !unconsumedEvents.contains(event))
          .toList()
        ..sort();

      expect(unconsumed, isEmpty,
          reason: 'Emitted natively with no Dart listener: $unconsumed');
    });
  });

  group('bindings that shipped on one side only', () {
    // Each of these was handled natively, or called from Dart, without the
    // other side. See MOBILE-5831 and MOBILE-6030.
    const bothPlatforms = <String>[
      'channel#enableChannelCreation',
      'featureFlagManager#resultCacheGetFlag',
      'featureFlagManager#resultCacheSetFlag',
      'featureFlagManager#resultCacheRemoveFlag',
      'isFlying',
    ];

    for (final method in bothPlatforms) {
      test('$method is bound on both platforms', () {
        expect(dartMethods, contains(method));
        expect(iosMethods, contains(method));
        expect(androidMethods, contains(method));
      });
    }

    const androidOnly = <String>[
      'liveUpdate#clearAll',
      'push#android#isNotificationChannelEnabled',
      'push#android#setNotificationConfig',
    ];

    for (final method in androidOnly) {
      test('$method is bound on Android', () {
        expect(dartMethods, contains(method));
        expect(androidMethods, contains(method));
      });
    }
  });
}

/// Matches the event channel names a plugin declares.
final RegExp _eventChannelPattern =
    RegExp(r'"(com\.airship\.flutter/event/[a-z_]+)"');

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
      throw StateError(
        'Unable to find the airship_flutter package root from ${Directory.current.path}',
      );
    }
    directory = parent;
  }
}

/// Collects every capture of [pattern] across the Dart sources.
Set<String> _dartMatches(Directory root, RegExp pattern) {
  return Directory('${root.path}/lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .expand(
        (file) => pattern
            .allMatches(file.readAsStringSync())
            .map((match) => match.group(1)!),
      )
      .toSet();
}

/// Collects every capture of [pattern] across the given native sources.
Set<String> _nativeNames(
  Directory root,
  List<String> relativePaths,
  RegExp pattern,
) {
  return relativePaths.expand((path) {
    final file = File('${root.path}/$path');
    if (!file.existsSync()) {
      throw StateError('Expected native source is missing: $path');
    }
    return pattern
        .allMatches(file.readAsStringSync())
        .map((match) => match.group(1)!);
  }).toSet();
}
