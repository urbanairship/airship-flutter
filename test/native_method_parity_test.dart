import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Verifies that every method the Dart layer invokes is actually handled by
/// both native plugins. Dart level tests mock the platform, so they cannot
/// catch a binding that was never wired up on one platform - this can.
void main() {
  final Directory root = _packageRoot();

  final Set<String> dartMethods = _dartMethods(Directory('${root.path}/lib'));

  final Set<String> iosMethods = _nativeMethods(
    File(
      '${root.path}/ios/airship_flutter/Sources/airship_flutter/AirshipPlugin.swift',
    ),
    RegExp(r'case\s+"([^"]+)"'),
  );

  final Set<String> androidMethods = _nativeMethods(
    File(
      '${root.path}/android/src/main/kotlin/com/airship/flutter/AirshipPlugin.kt',
    ),
    RegExp(r'"([^"]+)"\s*->'),
  );

  // Methods that only exist on one platform. Platform specific APIs are
  // normally named with an `#ios#` or `#android#` segment, these are the
  // exceptions.
  const Set<String> iosOnlyMethods = {
    "liveActivity#list",
    "liveActivity#listAll",
    "liveActivity#start",
    "liveActivity#stop",
    "liveActivity#update",
  };
  const Set<String> androidOnlyMethods = {};

  test('the Dart layer invokes methods', () {
    // Guards against the extraction below silently matching nothing.
    expect(dartMethods.length, greaterThan(50));
    expect(iosMethods, isNotEmpty);
    expect(androidMethods, isNotEmpty);
  });

  test('every Dart method is handled on iOS', () {
    final missing = dartMethods
        .where((method) => !method.contains("#android#"))
        .where((method) => !androidOnlyMethods.contains(method))
        .where((method) => !iosMethods.contains(method))
        .toList()
      ..sort();

    expect(missing, isEmpty, reason: "Missing iOS implementations: $missing");
  });

  test('every Dart method is handled on Android', () {
    final missing = dartMethods
        .where((method) => !method.contains("#ios#"))
        .where((method) => !iosOnlyMethods.contains(method))
        .where((method) => !androidMethods.contains(method))
        .toList()
      ..sort();

    expect(missing, isEmpty,
        reason: "Missing Android implementations: $missing");
  });

  group('feature flag and channel bindings', () {
    // These four were shipped in Dart without an iOS implementation, and
    // `resultCacheGetFlag` without an Android one. See MOBILE-5831.
    const methods = [
      "channel#enableChannelCreation",
      "featureFlagManager#resultCacheGetFlag",
      "featureFlagManager#resultCacheSetFlag",
      "featureFlagManager#resultCacheRemoveFlag",
    ];

    for (final method in methods) {
      test('$method is bound on both platforms', () {
        expect(dartMethods, contains(method));
        expect(iosMethods, contains(method));
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
        pubspec.readAsStringSync().contains("name: airship_flutter")) {
      return directory;
    }

    final parent = directory.parent;
    if (parent.path == directory.path) {
      throw StateError(
        "Unable to find the airship_flutter package root from ${Directory.current.path}",
      );
    }
    directory = parent;
  }
}

/// Extracts channel method names, e.g. `channel#getTags`, from the Dart source.
Set<String> _dartMethods(Directory lib) {
  final pattern = RegExp(
    '''["']([A-Za-z][A-Za-z0-9]*(?:#[A-Za-z][A-Za-z0-9]*)+)["']''',
  );

  return lib
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith(".dart"))
      .expand(
        (file) => pattern
            .allMatches(file.readAsStringSync())
            .map((match) => match.group(1)!),
      )
      .toSet();
}

/// Extracts the method names handled by a native plugin's method call switch.
Set<String> _nativeMethods(File plugin, RegExp pattern) {
  return pattern
      .allMatches(plugin.readAsStringSync())
      .map((match) => match.group(1)!)
      .where((method) => method.contains("#"))
      .toSet();
}
