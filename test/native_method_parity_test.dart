import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Verifies that the Dart layer and both native plugins agree on the method and
/// event channel names they exchange. Dart level tests mock the platform, so a
/// name that exists on only one side passes everywhere else. This checks both
/// directions: a method Dart calls that nothing handles, and a method or event
/// a platform handles that Dart never reaches. Event channels are checked per
/// platform, so one platform dropping a channel the other still emits fails.
///
/// The native names are read from source, so the extraction has limits. A
/// handler is any file that dispatches method calls, and a method is any string
/// literal branch in it, including each label of `"a", "b" ->`. A method name
/// assembled at runtime, or a string branch that is not a method name, is
/// invisible or reported as a method respectively.
void main() {
  final Directory root = _packageRoot();

  final List<File> androidHandlers = _sourceFiles(
    root,
    'android/src/main/kotlin',
    '.kt',
    marker: 'onMethodCall',
  );
  final List<File> iosHandlers = _sourceFiles(
    root,
    'ios/airship_flutter/Sources',
    '.swift',
    marker: 'FlutterMethodCall',
  );

  final Set<String> iosMethods = _branchLabels(
    iosHandlers,
    RegExp(r'case\s+((?:"[^"]*"\s*,\s*)*"[^"]+")\s*:'),
  );

  final Set<String> androidMethods = _branchLabels(
    androidHandlers,
    RegExp(r'((?:"[^"]*"\s*,\s*)*"[^"]+")\s*->'),
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

  final Set<String> iosEvents = _eventChannels(root, 'ios', '.swift');
  final Set<String> androidEvents = _eventChannels(root, 'android', '.kt');

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
    // Acknowledges the isolate the Android background handler runs in. iOS has
    // no equivalent, and accepts startBackgroundIsolate as a no-op.
    'backgroundIsolateStarted',
  };

  // Event channels one platform emits and the other does not.
  const Set<String> iosOnlyEvents = {
    'com.airship.flutter/event/ios_authorized_notification_settings_changed',
  };

  // Emitted natively with nothing listening in Dart. MOBILE-6037 decides
  // whether this becomes API or is removed.
  const Set<String> unconsumedEvents = {
    'com.airship.flutter/event/background_push_received',
  };

  test('the extraction finds names on every side', () {
    // Guards against a regex or a glob that silently matches nothing.
    expect(dartMethods.length, greaterThan(50));
    expect(iosMethods, isNotEmpty);
    expect(androidMethods, isNotEmpty);
    expect(dartEvents, isNotEmpty);
    expect(iosEvents, isNotEmpty);
    expect(androidEvents, isNotEmpty);

    expect(iosHandlers.map((file) => file.uri.pathSegments.last),
        contains('AirshipPlugin.swift'));
    expect(androidHandlers.map((file) => file.uri.pathSegments.last),
        contains('AirshipPlugin.kt'));
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
    test('iOS emits every channel Dart listens to', () {
      final missing =
          dartEvents.where((event) => !iosEvents.contains(event)).toList()
            ..sort();

      expect(missing, isEmpty,
          reason: 'Listened to in Dart but not emitted on iOS: $missing');
    });

    test('Android emits every channel Dart listens to', () {
      final missing = dartEvents
          .where((event) => !iosOnlyEvents.contains(event))
          .where((event) => !androidEvents.contains(event))
          .toList()
        ..sort();

      expect(missing, isEmpty,
          reason: 'Listened to in Dart but not emitted on Android: $missing');
    });

    test('Dart listens to every channel iOS emits', () {
      final unconsumed = iosEvents
          .where((event) => !unconsumedEvents.contains(event))
          .where((event) => !dartEvents.contains(event))
          .toList()
        ..sort();

      expect(unconsumed, isEmpty,
          reason: 'Emitted on iOS with no Dart listener: $unconsumed');
    });

    test('Dart listens to every channel Android emits', () {
      final unconsumed = androidEvents
          .where((event) => !unconsumedEvents.contains(event))
          .where((event) => !dartEvents.contains(event))
          .toList()
        ..sort();

      expect(unconsumed, isEmpty,
          reason: 'Emitted on Android with no Dart listener: $unconsumed');
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
      'liveUpdate#clearAll',
    ];

    for (final method in bothPlatforms) {
      test('$method is bound on both platforms', () {
        expect(dartMethods, contains(method));
        expect(iosMethods, contains(method));
        expect(androidMethods, contains(method));
      });
    }

    const androidOnly = <String>[
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

/// Every source file under [relativeDir] with [extension], or only those that
/// contain [marker] when one is given.
List<File> _sourceFiles(
  Directory root,
  String relativeDir,
  String extension, {
  String? marker,
}) {
  final Directory directory = Directory('${root.path}/$relativeDir');
  if (!directory.existsSync()) {
    throw StateError('Expected native source directory is missing: $relativeDir');
  }
  return directory
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith(extension))
      .where((file) => marker == null || file.readAsStringSync().contains(marker))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
}

/// Every string literal label of every branch matched by [pattern], so a
/// branch such as `"a", "b" ->` contributes both names.
Set<String> _branchLabels(List<File> files, RegExp pattern) {
  final RegExp literal = RegExp(r'"([^"]+)"');
  return files
      .expand((file) => pattern.allMatches(file.readAsStringSync()))
      .expand((match) => literal.allMatches(match.group(1)!))
      .map((match) => match.group(1)!)
      .toSet();
}

/// The event channel names declared anywhere in a platform's sources.
Set<String> _eventChannels(Directory root, String platform, String extension) {
  final RegExp channel = RegExp(r'"(com\.airship\.flutter/event/[a-z_]+)"');
  final String dir = platform == 'ios'
      ? 'ios/airship_flutter/Sources'
      : 'android/src/main/kotlin';
  return _sourceFiles(root, dir, extension)
      .expand((file) => channel.allMatches(file.readAsStringSync()))
      .map((match) => match.group(1)!)
      .toSet();
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
