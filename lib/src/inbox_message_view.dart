import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class InboxMessageView extends StatefulWidget {
  final String messageId;
  final onLoadStarted;
  final onLoadFinished;
  final onLoadError;
  final onClose;

  InboxMessageView({
    Key key,
    @required this.messageId,
    this.onLoadStarted,
    this.onLoadFinished,
    this.onLoadError,
    this.onClose,
  });

  @override
  _InboxMessageViewState createState() => _InboxMessageViewState();
}

class _InboxMessageViewState extends State<InboxMessageView> {
  MethodChannel _channel;

  Future<void> onPlatformViewCreated(id) async {
    _channel =  new MethodChannel('com.airship.flutter/InboxMessageView_$id');
    loadMessage(widget.messageId);
  }

  Future<void> loadMessage(String messageId) async {
    if (messageId == null) {
      throw ArgumentError.notNull('messageId');
    }

    return _channel.invokeMethod('loadMessage', messageId);
  }

  @override
    Widget build(BuildContext context) {
    if(defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'com.airship.flutter/InboxMessageView',
        onPlatformViewCreated: onPlatformViewCreated,
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else if(defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'com.airship.flutter/InboxMessageView',
        onPlatformViewCreated: onPlatformViewCreated,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }

    return new Text('$defaultTargetPlatform is not yet supported by this plugin');
  }
}