import 'package:airship_flutter/airship_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('com.airship.flutter/airship');

  final List<MethodCall> calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      calls.add(call);
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('enableChannelCreation sends the method with no arguments', () async {
    await Airship.channel.enableChannelCreation();

    expect(calls, hasLength(1));
    expect(calls.first.method, "channel#enableChannelCreation");
    expect(calls.first.arguments, isNull);
  });
}
