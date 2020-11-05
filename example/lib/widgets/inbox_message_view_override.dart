import 'package:airship_flutter/airship_flutter.dart';
import 'package:flutter/foundation.dart';

class InboxMessageViewOverride extends InboxMessageView {

  InboxMessageViewOverride({
    @required messageId, onLoadStarted, onLoadFinished, onLoadError, onClose
  }) : super(messageId: messageId, onLoadStarted: onLoadStarted, onLoadFinished: onLoadFinished, onLoadError: onLoadError, onClose: onClose)
  {
    InboxMessageView.hybridComposition = true;
  }
}