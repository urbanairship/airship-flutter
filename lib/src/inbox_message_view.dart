import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'airship.dart';

class InboxMessageView extends StatefulWidget {
  final InboxMessageViewCreatedCallback onViewCreated;

  InboxMessageView({
    Key key,
    @required this.onViewCreated
  });

  @override
  _InboxMessageViewState createState() => _InboxMessageViewState();
}

typedef void InboxMessageViewCreatedCallback(InboxMessageViewController controller);

class InboxMessageViewController {

  MethodChannel _channel;

  InboxMessageViewController.init(int id) {
    _channel =  new MethodChannel('com.airship.flutter/InboxMessageView_$id');
  }

  Future<void> loadMessage(InboxMessage message) async {
    if (message == null) {
      throw ArgumentError.notNull('message');
    }

    return _channel.invokeMethod('loadMessage', message.messageId);
  }
}

class _InboxMessageViewState extends State<InboxMessageView> {

  Future<void> onPlatformViewCreated(id) async {
    if (widget.onViewCreated == null) {
      return;
    }
    widget.onViewCreated(new InboxMessageViewController.init(id));
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