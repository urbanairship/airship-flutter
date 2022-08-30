import 'package:airship_flutter/src/airship_flutter.dart';
import 'package:airship_flutter/src/components/airship_ios.dart';
import 'package:airship_flutter/src/components/airship_push.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  /// test Airship IOS
  group("Airship.ios", () {
    test('ios namespace', () async {
      expect( Airship.iOS, isA<AirshipIOS>());
    });
  });

  /// test Airship Push
  group("Airship.push", () {
    test('ios namespace', () async {
      expect( Airship.push, isA<AirshipPush>());
    });
  });
}
