import 'package:flutter/material.dart';
import 'package:airship_flutter/airship.dart';
import 'package:airship_example/styles.dart';
import 'package:flutter/services.dart';

class MessageView extends StatefulWidget {
  final String messageId;

  MessageView({this.messageId});

  @override
  _MessageViewState createState() => _MessageViewState();
}

class _MessageViewState extends State<MessageView>  {
  bool isLoading = true;

  @override
  void initState() {
    Airship.trackScreen('Message View');
    super.initState();
  }

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
              title: message != null ? Text("${message.title}") : Container(),
              backgroundColor: Styles.background,
            ),
            body: Stack(
                children: <Widget>[
                  isLoading
                      ? Center(child: CircularProgressIndicator())
                      : Container(),
                  InboxMessageView(messageId: widget.messageId, handleLoadStarted: onLoadStarted, handleLoadFinished: onLoadFinished, handleLoadError: onLoadError, handleClose: onClose)
                ]),
          );
        });
  }

  onStarted() {
    setState(() {
      isLoading = true;
    });
  }

  onLoadStarted() {
    setState(() {
      isLoading = true;
    });
  }

  onLoadFinished() {
    setState(() {
      isLoading = false;
    });
  }

  onLoadError(PlatformException e) {
    setState(() {
      isLoading = false;
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(e.message != null ? e.message : "Unable to load message"),
            content: Text(e.details != null ? e.details : ""),
          )
      );
    });
  }

  onClose() {
    setState(() {
      isLoading = false;
    });
  }
}