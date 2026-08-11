import 'dart:async';
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

/// Embedded platform view. Sizes from its parent's constraints; when the height
/// is unbounded, the native side measures the auto-height scene content and the
/// view adopts it. Scenes that cannot measure fill the space they are given.
class AirshipEmbeddedView extends StatefulWidget {
  /// The embedded view Id.
  final String embeddedId;

  /// Optional fixed width. Prefer sizing with the parent, e.g. a [SizedBox].
  final double? parentWidth;

  /// Optional fixed height. Prefer sizing with the parent, e.g. a [SizedBox].
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

  // The sizing mode the native view is in. Null until the first layout decides
  // the mode to create it with.
  bool? _nativeSelfSizing;

  /// The view measures its own content only when nothing else determines its
  /// height: no explicit [AirshipEmbeddedView.parentHeight], and a parent that
  /// leaves the height unbounded.
  @visibleForTesting
  static bool isSelfSizing({
    required BoxConstraints constraints,
    double? parentHeight,
  }) =>
      parentHeight == null && !constraints.hasBoundedHeight;

  bool _isSelfSizing(BoxConstraints constraints) => isSelfSizing(
        constraints: constraints,
        parentHeight: widget.parentHeight,
      );

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
        setState(() {
          _isEmbeddedAvailable = v;
          // Old content's height must not size whatever arrives next.
          if (!v) _contentHeight = null;
        });
      }
    });
  }

  Future<void> _methodCallHandler(MethodCall call) async {
    switch (call.method) {
      case 'onSizeUpdate':
        final args = (call.arguments as Map?)?.cast<String, dynamic>();
        final height = (args?['height'] as num?)?.toDouble();
        // Degenerate reports happen transiently during dismissal; hold the last
        // real height and let the availability check collapse the view instead.
        if (height != null &&
            height > _minContentHeight &&
            mounted &&
            height != _contentHeight) {
          setState(() => _contentHeight = height);
        }
        break;
      default:
        print('Unknown method.');
    }
  }

  void _onPlatformViewCreated(int id) {
    _channel?.setMethodCallHandler(null);
    final channel = MethodChannel('com.airship.flutter/EmbeddedView_$id')
      ..setMethodCallHandler(_methodCallHandler);
    _channel = channel;

    // The mode may have changed between the layout that supplied the creation
    // params and the view actually being created, so restate it.
    final selfSizing = _nativeSelfSizing;
    if (selfSizing != null) {
      channel
          .invokeMethod('setSizeToContent', {'sizeToContent': selfSizing})
          .catchError((Object _) => null);
    }
  }

  /// Keeps the native sizing mode in step with the constraints, so a parent that
  /// changes between bounding and not bounding the height is followed.
  void _syncSelfSizing(bool selfSizing) {
    if (_nativeSelfSizing == selfSizing) {
      return;
    }
    final isFirstLayout = _nativeSelfSizing == null;
    _nativeSelfSizing = selfSizing;

    // The first value is carried by the creation params instead.
    if (isFirstLayout) {
      return;
    }

    final channel = _channel;
    if (channel == null) {
      return;
    }
    // Runs during layout, so defer out of the frame; by then the view may be
    // gone or replaced, so bail out rather than poke a dead channel.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !identical(_channel, channel)) return;
      channel
          .invokeMethod('setSizeToContent', {'sizeToContent': selfSizing})
          .catchError((Object _) => null);
    });
  }

  /// Heights at or below this are treated as the native side failing to resolve
  /// one, rather than as a real content height.
  static const double _minContentHeight = 1.0;

  /// Resolves the platform view's size from the parent's constraints and, when
  /// self sizing, the last reported content height. The fallbacks apply while a
  /// dimension is unbounded and unmeasured.
  @visibleForTesting
  static Size resolveSize({
    required BoxConstraints constraints,
    required double fallbackWidth,
    required double fallbackHeight,
    double? parentWidth,
    double? parentHeight,
    double? contentHeight,
  }) {
    final width = parentWidth ??
        (constraints.hasBoundedWidth ? constraints.maxWidth : fallbackWidth);

    // A report at or below the floor means "could not resolve", not "empty";
    // gone content is handled by the availability check, so stay visible.
    final measured = (contentHeight != null && contentHeight > _minContentHeight)
        ? contentHeight
        : null;

    // Until a usable measurement arrives, take the available space so native has
    // room to lay out; whatever the view does not need is returned on report.
    final height = parentHeight ??
        (constraints.hasBoundedHeight
            ? constraints.maxHeight
            : (measured ?? fallbackHeight));

    return Size(width, height);
  }

  Size _resolveSize(BuildContext context, BoxConstraints constraints) {
    return resolveSize(
      constraints: constraints,
      fallbackWidth: MediaQuery.of(context).size.width,
      fallbackHeight: MediaQuery.of(context).size.height,
      parentWidth: widget.parentWidth,
      parentHeight: widget.parentHeight,
      contentHeight: _contentHeight,
    );
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
    return _wrapWithLayoutBuilder((_) => view);
  }

  /// The platform view has to be created knowing whether it should measure its
  /// own content, so it is built inside the layout pass that resolves that.
  Widget _wrapWithLayoutBuilder(Widget Function(bool selfSizing) viewBuilder) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final selfSizing = _isSelfSizing(constraints);
        _syncSelfSizing(selfSizing);
        final view = viewBuilder(selfSizing);
        final size = _resolveSize(context, constraints);

        return Center(child: buildReadyView(context, view, size));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (defaultTargetPlatform == TargetPlatform.android) {
      return _wrapWithLayoutBuilder(_getAndroidView);
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _wrapWithLayoutBuilder(_getIOSView);
    }

    return Text('$defaultTargetPlatform is not yet supported by this plugin');
  }

  Map<String, Object?> _creationParams(bool selfSizing) {
    return <String, Object?>{
      'embeddedId': widget.embeddedId,
      'selection': widget.selection?.toJson(),
      'sizeToContent': selfSizing,
    };
  }

  Widget _getIOSView(bool selfSizing) {
    return UiKitView(
      viewType: 'com.airship.flutter/EmbeddedView',
      onPlatformViewCreated: _onPlatformViewCreated,
      creationParams: _creationParams(selfSizing),
      creationParamsCodec: const StandardMessageCodec(),
    );
  }

  Widget _getAndroidView(bool selfSizing) {
    if (AirshipEmbeddedView.hybridComposition) {
      return PlatformViewLink(
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
            creationParams: _creationParams(selfSizing),
            creationParamsCodec: const StandardMessageCodec(),
            onFocus: () {
              params.onFocusChanged(true);
            },
          )
            ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
            ..addOnPlatformViewCreatedListener(_onPlatformViewCreated)
            ..create();
        },
      );
    } else {
      return AndroidView(
        viewType: 'com.airship.flutter/EmbeddedView',
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParams: _creationParams(selfSizing),
        creationParamsCodec: const StandardMessageCodec(),
      );
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
