import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:airship_flutter/airship_flutter.dart';

/// Embedded platform view.
///
/// Note: When an embedded view is set to display with its height set to `auto`
/// the embedded view will size to its native aspect ratio. Any remaining space
/// in the parent view will be apparent.
class AirshipEmbeddedView extends StatefulWidget {
  /// The embedded view Id.
  final String embeddedId;

  /// Optional parent width. If not provided, the widget will use available width.
  final double? parentWidth;

  /// Optional parent height. If not provided, the widget will use available height.
  /// Use parentHeight for constant height instead of a height-constrained container.
  /// This allows proper collapse to 0 height when the view is dismissed.
  final double? parentHeight;

  /// A flag to use flutter hybrid composition method or not. Default to false.
  static bool hybridComposition = false;

  AirshipEmbeddedView({
    required this.embeddedId,
    this.parentWidth,
    this.parentHeight,
  });

  @override
  AirshipEmbeddedViewState createState() => AirshipEmbeddedViewState();
}

class AirshipEmbeddedViewState extends State<AirshipEmbeddedView>
    with AutomaticKeepAliveClientMixin<AirshipEmbeddedView> {
  late MethodChannel _channel;
  late Stream<bool> _readyStream;
  bool? _isEmbeddedAvailable;

  @override
  void initState() {
    super.initState();
    _readyStream =
        Airship.inApp.isEmbeddedAvailableStream(embeddedId: widget.embeddedId);
    _readyStream.listen((isEmbeddedAvailable) {
      if (mounted) {
        setState(() {
          _isEmbeddedAvailable = isEmbeddedAvailable;
        });
      }
    });
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
  }

  Widget buildReadyView(BuildContext context, Widget view, Size availableSize) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _isEmbeddedAvailable == true
          ? SizedBox(
              key: ValueKey<bool>(true),
              width: widget.parentWidth ?? availableSize.width,
              height: widget.parentHeight ?? availableSize.height,
              child: view,
            )
          : SizedBox(key: ValueKey<bool>(false), height: 0),
    );
  }

  Widget wrapWithLayoutBuilder(Widget view) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final availableSize = MediaQuery.of(context).size;

        return Center(child: buildReadyView(context, view, availableSize));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (defaultTargetPlatform == TargetPlatform.android) {
      return _getAndroidView();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return wrapWithLayoutBuilder(
        UiKitView(
          viewType: 'com.airship.flutter/EmbeddedView',
          onPlatformViewCreated: _onPlatformViewCreated,
          creationParams: <String, Object?>{
            'embeddedId': widget.embeddedId,
          },
          creationParamsCodec: const StandardMessageCodec(),
        ),
      );
    }

    return Text('$defaultTargetPlatform is not yet supported by this plugin');
  }

  Widget _getAndroidView() {
    if (AirshipEmbeddedView.hybridComposition) {
      return wrapWithLayoutBuilder(PlatformViewLink(
        viewType: 'com.airship.flutter/EmbeddedView',
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
            viewType: 'com.airship.flutter/EmbeddedView',
            layoutDirection: TextDirection.ltr,
            creationParams: <String, Object?>{
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
      ));
    } else {
      return wrapWithLayoutBuilder(AndroidView(
        viewType: 'com.airship.flutter/EmbeddedView',
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParams: <String, Object?>{
          'embeddedId': widget.embeddedId,
        },
        creationParamsCodec: const StandardMessageCodec(),
      ));
    }
  }

  @override
  void dispose() {
    _channel.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
