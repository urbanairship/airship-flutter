import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Inbox message view component.
class InboxMessageView extends StatelessWidget {
  /// The message Id.
  final String messageId;

  /// A callback when the view starts loading a message.
  final void Function()? onLoadStarted;

  /// A callback when the view finishes loading a message.
  final void Function()? onLoadFinished;

  /// A callback when the view fails to load a message with an error.
  final void Function(PlatformException)? onLoadError;

  /// A callback when the message is closed.
  final void Function()? onClose;

  /// A flag to use flutter hybrid composition method or not. Default to false.
  static bool hybridComposition = false;

  InboxMessageView(
      {required this.messageId,
      this.onLoadStarted,
      this.onLoadFinished,
      this.onLoadError,
      this.onClose});

  Future<void> onPlatformViewCreated(id) async {
    MethodChannel _channel =
        new MethodChannel('com.airship.flutter/InboxMessageView_$id');
    _channel.setMethodCallHandler(methodCallHandler);
    _channel.invokeMethod('loadMessage', messageId).catchError((error) {
      if (onLoadError != null) {
        onLoadError!(error);
      }
    });
  }

  Future<void> methodCallHandler(MethodCall call) async {
    switch (call.method) {
      case 'onLoadStarted':
        if (onLoadStarted != null) {
          onLoadStarted!();
        }
        break;
      case 'onLoadFinished':
        if (onLoadFinished != null) {
          onLoadFinished!();
        }
        break;
      case 'onClose':
        if (onClose != null) {
          onClose!();
        }
        break;
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
        viewType: 'com.airship.flutter/InboxMessageView',
        onPlatformViewCreated: onPlatformViewCreated,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }

    return new Text(
        '$defaultTargetPlatform is not yet supported by this plugin');
  }

  Widget getAndroidView() {
    if (hybridComposition) {
      // Hybrid Composition method
      return PlatformViewLink(
        viewType: 'com.airship.flutter/InboxMessageView',
        surfaceFactory:
            (BuildContext context, PlatformViewController controller) {
          return AndroidViewSurface(
            controller: controller as AndroidViewController,
            gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          );
        },
        onCreatePlatformView: (PlatformViewCreationParams params) {
          return PlatformViewsService.initSurfaceAndroidView(
            id: params.id,
            viewType: 'com.airship.flutter/InboxMessageView',
            layoutDirection: TextDirection.ltr,
            creationParams: <String, dynamic>{},
            creationParamsCodec: StandardMessageCodec(),
          )
            ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
            ..addOnPlatformViewCreatedListener(onPlatformViewCreated)
            ..create();
        },
      );
    } else {
      // Display View method
      return AndroidView(
        viewType: 'com.airship.flutter/InboxMessageView',
        onPlatformViewCreated: onPlatformViewCreated,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
  }
}
