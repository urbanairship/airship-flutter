import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

/// Embedded view component.
class EmbeddedView extends StatefulWidget {
  /// The embedded view Id.
  final String embeddedId;

  /// A flag to use flutter hybrid composition method or not. Default to false.
  static bool hybridComposition = false;

  EmbeddedView({required this.embeddedId});

  @override
  EmbeddedViewState createState() => EmbeddedViewState();
}

class EmbeddedViewState extends State<EmbeddedView> {
  late MethodChannel _channel;

  double _nativeViewWidth = 0;
  double _nativeViewHeight = 0;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _getNativeViewSize() async {
    try {
      final size = await _channel.invokeMethod<Map>('getSize');
      setState(() {
        _nativeViewWidth = size?['width'];
        _nativeViewHeight = size?['height'];
      });
    } on PlatformException catch (e) {
      print("Failed to get native view size: '${e.message}'.");
    }
  }

  Future<void> _methodCallHandler(MethodCall call) async {
    switch (call.method) {
      default:
        print('Unknown method.');
    }
  }

  Future<void> _onPlatformViewCreated(int id) async {
    _channel = MethodChannel('com.airship.flutter/EmbeddedView_$id');
    _channel.setMethodCallHandler(_methodCallHandler);
    _getNativeViewSize();
  }


  /// Fall back to screen-sized constraints when constraints can be inferred
  Widget wrapWithLayoutBuilder(Widget view) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double width = _nativeViewWidth;
        double height = _nativeViewHeight;

        if (width == 0 || width == double.infinity) {
          width = MediaQuery.of(context).size.width;
        }

        if (height == 0 || height == double.infinity) {
          height = MediaQuery.of(context).size.height;
        }

        return ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 10,
              minHeight: 10,
              maxWidth: MediaQuery.of(context).size.width,
              maxHeight: MediaQuery.of(context).size.height
            ),
            child: view,
          );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _getAndroidView();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return wrapWithLayoutBuilder(
        UiKitView(
          viewType: 'com.airship.flutter/EmbeddedView',
          onPlatformViewCreated: _onPlatformViewCreated,
          creationParams: <String, dynamic>{
            'embeddedId': widget.embeddedId,
          },
          creationParamsCodec: const StandardMessageCodec(),
        ),
      );
    }

    return Text('$defaultTargetPlatform is not yet supported by this plugin');
  }

  Widget _getAndroidView() {
    if (EmbeddedView.hybridComposition) {
      return wrapWithLayoutBuilder(
          PlatformViewLink(
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
                  'embeddedId': widget.embeddedId,
                },
                creationParamsCodec: const StandardMessageCodec(),
                onFocus: () {
                  params.onFocusChanged(true);
                },
              )
                ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
                ..create();
            },
          )
      );
    } else {
      return wrapWithLayoutBuilder(
        AndroidView(
          viewType: 'com.airship.flutter/EmbeddedView',
          onPlatformViewCreated: _onPlatformViewCreated,
          creationParams: <String, dynamic>{
            'embeddedId': widget.embeddedId,
          },
          creationParamsCodec: const StandardMessageCodec(),
        )
      );
    }
  }

  @override
  void dispose() {
    _channel.setMethodCallHandler(null);
    super.dispose();
  }
}
