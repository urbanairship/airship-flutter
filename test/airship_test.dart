import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:airship/airship.dart';

void main() {
  const MethodChannel channel = MethodChannel('airship');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });
//
//  test('getPlatformVersion', () async {
//    expect(await Airship.platformVersion, '42');
//  });
}
