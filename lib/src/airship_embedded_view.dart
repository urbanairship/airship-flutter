import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Embedded view component.
class EmbeddedView extends StatelessWidget {
  /// The embedded view Id.
  final String embeddedId;

  /// A flag to use flutter hybrid composition method or not. Default to false.
  static bool hybridComposition = false;

  EmbeddedView({required this.embeddedId});

  Future<void> onPlatformViewCreated(id) async {
    var channel = MethodChannel('com.airship.flutter/EmbeddedView_$id');
    channel.setMethodCallHandler(methodCallHandler);
  }

  Future<void> methodCallHandler(MethodCall call) async {
    switch (call.method) {
      default:
        print('Unknown method.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return getAndroidView();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'com.airship.flutter/EmbeddedView',
        onPlatformViewCreated: onPlatformViewCreated,
        creationParams: <String, dynamic>{
          'embeddedId': embeddedId,
        },
        creationParamsCodec: const StandardMessageCodec(),
      );
    }

    return Text('$defaultTargetPlatform is not yet supported by this plugin');
  }

  Widget getAndroidView() {
    if (hybridComposition) {
      // Hybrid Composition method
      return PlatformViewLink(
        viewType: 'com.airship.flutter/EmbeddedView',
        surfaceFactory: (BuildContext context, PlatformViewController controller) {
          return AndroidViewSurface(
            controller: controller as AndroidViewController,
            gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          );
        },
        onCreatePlatformView: (PlatformViewCreationParams params) {
          return PlatformViewsService.initSurfaceAndroidView(
            id: params.id,
            viewType: 'com.airship.flutter/EmbeddedView',
            layoutDirection: TextDirection.ltr,
            creationParams: <String, dynamic>{
              'embeddedId': embeddedId,
            },
            creationParamsCodec: const StandardMessageCodec(),
            onFocus: () {
              params.onFocusChanged(true);
            },
          )
            ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
            ..create();
        },
      );
    } else {
      // Display View method
      return AndroidView(
        viewType: 'com.airship.flutter/EmbeddedView',
        onPlatformViewCreated: onPlatformViewCreated,
        creationParams: <String, dynamic>{
          'embeddedId': embeddedId,
        },
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
  }
}
