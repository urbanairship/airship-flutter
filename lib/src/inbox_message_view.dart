import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class InboxMessageView extends StatelessWidget {
  final String messageId;
  final void Function() handleLoadStarted;
  final void Function() handleLoadFinished;
  final void Function(PlatformException) handleLoadError;
  final void Function() handleClose;

  InboxMessageView({
    @required this.messageId, this.handleLoadStarted, this.handleLoadFinished, this.handleLoadError, this.handleClose
  });

  Future<void> onPlatformViewCreated(id) async {

    MethodChannel _channel = new MethodChannel('com.airship.flutter/InboxMessageView_$id');
    _channel.setMethodCallHandler(methodCallHandler);
    _channel.invokeMethod('loadMessage', messageId).catchError( (error) {
      handleLoadError(error);
    });
  }

  Future<void> methodCallHandler(MethodCall call) async {
    switch (call.method) {
      case 'onLoadStarted':
        handleLoadStarted();
        break;
      case 'onLoadFinished':
        handleLoadFinished();
        break;
      case 'onClose':
        handleClose();
        break;
      default:
        print('Unknown method.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'com.airship.flutter/InboxMessageView',
        onPlatformViewCreated: onPlatformViewCreated,
        creationParamsCodec: const StandardMessageCodec(),
      );
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
}
