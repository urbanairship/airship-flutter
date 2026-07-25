import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:airship_flutter/airship_flutter.dart';

/// Controls which pending embedded content instance is displayed when more
/// than one is available for the same embedded ID.
abstract class AirshipEmbeddedViewSelection {
  const AirshipEmbeddedViewSelection();

  Map<String, Object?> toJson();
}

/// Display by priority ordering. This is the default.
class AirshipEmbeddedViewSelectionPriority extends AirshipEmbeddedViewSelection {
  const AirshipEmbeddedViewSelectionPriority();

  @override
  Map<String, Object?> toJson() => const {'type': 'priority'};
}

/// Display a specific pending instance by its instance ID.
class AirshipEmbeddedViewSelectionInstanceId extends AirshipEmbeddedViewSelection {
  final String instanceId;

  const AirshipEmbeddedViewSelectionInstanceId(this.instanceId);

  @override
  Map<String, Object?> toJson() => {
        'type': 'instance_id',
        'instanceId': instanceId,
      };
}

/// Embedded platform view.
///
/// When [parentHeight] is omitted, the native side measures the embedded
/// content and reports its height back, and the widget sizes to match.
class AirshipEmbeddedView extends StatefulWidget {
  /// The embedded view Id.
  final String embeddedId;

  /// Optional parent width. If not provided, the widget will use available width.
  final double? parentWidth;

  /// Optional fixed height. If not provided, the view sizes to its content.
  /// Percent-sized content resolves against this height when set.
  final double? parentHeight;

  /// How to select which pending content to display when more than one is
  /// available. Defaults to priority ordering.
  final AirshipEmbeddedViewSelection? selection;

  /// A flag to use flutter hybrid composition method or not. Default to false.
  static bool hybridComposition = false;

  AirshipEmbeddedView({
    required this.embeddedId,
    this.parentWidth,
    this.parentHeight,
    this.selection,
  });

  @override
  AirshipEmbeddedViewState createState() => AirshipEmbeddedViewState();
}

class AirshipEmbeddedViewState extends State<AirshipEmbeddedView>
    with AutomaticKeepAliveClientMixin<AirshipEmbeddedView> {
  MethodChannel? _channel;
  late Stream<bool> _readyStream;
  late final StreamSubscription<bool> _readySubscription;

  bool? _isEmbeddedAvailable;

  // Content height reported by the native side. Null until the first report.
  double? _contentHeight;

  @override
  void initState() {
    super.initState();

    // Get seed value once
    _isEmbeddedAvailable =
        Airship.inApp.isEmbeddedAvailable(embeddedId: widget.embeddedId);

    // Then listen for changes
    _readyStream =
        Airship.inApp.isEmbeddedAvailableStream(embeddedId: widget.embeddedId);
    _readySubscription = _readyStream.listen((v) {
      if (mounted && v != _isEmbeddedAvailable) {
        setState(() => _isEmbeddedAvailable = v);
      }
    });
  }

  Future<void> _methodCallHandler(MethodCall call) async {
    switch (call.method) {
      case 'onSizeUpdate':
        final args = (call.arguments as Map?)?.cast<String, dynamic>();
        final height = (args?['height'] as num?)?.toDouble();
        // Only self-size when the caller hasn't pinned an explicit height.
        if (height != null && mounted && widget.parentHeight == null) {
          setState(() => _contentHeight = height);
        }
        break;
      default:
        print('Unknown method.');
    }
  }

  void _onPlatformViewCreated(int id) {
    _channel?.setMethodCallHandler(null);
    _channel = MethodChannel('com.airship.flutter/EmbeddedView_$id')
      ..setMethodCallHandler(_methodCallHandler);
  }

  Widget buildReadyView(
      BuildContext context, Widget view, BoxConstraints constraints) {
    final width = widget.parentWidth ??
        (constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width);

    // Never zero: platform views can't be created or resized to an empty size.
    final height = max(1.0, widget.parentHeight ?? _contentHeight ?? 1.0);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _isEmbeddedAvailable == true
          ? SizedBox(
              key: ValueKey<bool>(true),
              width: width,
              height: height,
              child: view,
            )
          : SizedBox(key: ValueKey<bool>(false), height: 0),
    );
  }

  Widget wrapWithLayoutBuilder(Widget view) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Center(child: buildReadyView(context, view, constraints));
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
            'selection': widget.selection?.toJson(),
            'parentHeight': widget.parentHeight,
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
              'selection': widget.selection?.toJson(),
              'parentHeight': widget.parentHeight,
            },
            creationParamsCodec: const StandardMessageCodec(),
            onFocus: () {
              params.onFocusChanged(true);
            },
          )
            ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
            ..addOnPlatformViewCreatedListener(_onPlatformViewCreated)
            ..create();
        },
      ));
    } else {
      return wrapWithLayoutBuilder(AndroidView(
        viewType: 'com.airship.flutter/EmbeddedView',
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParams: <String, Object?>{
          'embeddedId': widget.embeddedId,
          'selection': widget.selection?.toJson(),
          'parentHeight': widget.parentHeight,
        },
        creationParamsCodec: const StandardMessageCodec(),
      ));
    }
  }

  @override
  void dispose() {
    _readySubscription.cancel();
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
