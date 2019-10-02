import 'package:flutter/material.dart';
import 'package:airship/airship.dart';
import 'package:airship_example/styles.dart';

class MessageView extends StatelessWidget {
  final InboxMessage message;
  final updateParent;

  MessageView({this.message, this.updateParent});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("${message.title}"),
          backgroundColor: Styles.background,
        ),
        body: Container(
          child: InboxMessageView(onViewCreated:onInboxMessageViewCreated),
        )
    );
  }

  void onInboxMessageViewCreated(InboxMessageViewController controller) {
    Airship.inboxMessages.then((List<InboxMessage> messages) {
      if (message != null) {
        debugPrint("Loading message: ${message.title}");
        controller.loadMessage(message);
        Airship.markInboxMessageRead(message);
        // Add to message updated sink to indicate message was read
        updateParent();
      } else {
        debugPrint("Attempted to load message view for null message");
      }
    });
  }
}