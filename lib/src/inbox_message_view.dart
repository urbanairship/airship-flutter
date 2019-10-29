import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'airship.dart';

class InboxMessageView extends StatefulWidget {
  final InboxMessage message;
  final onLoadStarted;
  final onLoadFinished;
  final onLoadError;
  final onClose;


  InboxMessageView({
    Key key,
    @required this.message,
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
    if (widget.onLoadStarted != null) {
      widget.onLoadStarted();
    }
    loadMessage(widget.message).then((message) {
      if (widget.onLoadFinished != null) {
        widget.onLoadFinished();
      }
    });
  }

  Future<void> loadMessage(InboxMessage message) async {
    if (message == null) {
      if (widget.onLoadError != null) {
        widget.onLoadError(ArgumentError.notNull('message'));
      }
      throw ArgumentError.notNull('message');
    }


    return _channel.invokeMethod('loadMessage', message.messageId);
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

  dispose() {
    super.dispose();

    if (widget.onClose != null) {
      widget.onClose();
    }
  }
}