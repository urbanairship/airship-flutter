import 'package:flutter/material.dart';
import 'package:airship/airship.dart';
import 'package:airship_example/styles.dart';

class MessageView extends StatefulWidget {
  final String messageId;

  MessageView({this.messageId});

  @override
  _MessageViewState createState() => _MessageViewState();
}

class _MessageViewState extends State<MessageView>  {
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<InboxMessage>>(
        future: Airship.inboxMessages,
        builder: (context, snapshot) {
          InboxMessage message;

          List<InboxMessage> list = [];

          if (snapshot.hasData) {
            list = List<InboxMessage>.from(snapshot.data);
          }

          message = list.firstWhere((thisMessage) =>
          widget.messageId == thisMessage.messageId,
              orElse: () => null);

          return Scaffold(
            appBar: AppBar(
              title: Text("${message.title}"),
              backgroundColor: Styles.background,
            ),
            body: Stack(
                children: <Widget>[
                  isLoading
                      ? Center(child: CircularProgressIndicator())
                      : Container(),
                  InboxMessageView(messageId: widget.messageId,
                      onLoadStarted: onStarted,
                      onLoadFinished: onLoadFinished)
                ]),
          );
        });
  }

  onStarted() {
    setState(() {
      isLoading = true;
    });
  }

  onLoadFinished() {
    setState(() {
      isLoading = false;
    });
  }
}