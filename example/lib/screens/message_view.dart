import 'package:flutter/material.dart';
import 'package:airship_flutter/airship_flutter.dart';
import 'package:airship_example/styles.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';

class MessageView extends StatefulWidget {
  final String messageId;

  MessageView({required this.messageId});

  @override
  _MessageViewState createState() => _MessageViewState();
}

class _MessageViewState extends State<MessageView> {
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
          List<InboxMessage> list = [];

          if (snapshot.hasData) {
            list = snapshot.data!;
          }

          InboxMessage? message = list.firstWhereOrNull(
                  (thisMessage) => widget.messageId == thisMessage.messageId);

          return Scaffold(
            appBar: AppBar(
              title: message != null ? Text("${message.title}") : Container(),
              backgroundColor: Styles.background,
            ),
            body: Stack(children: <Widget>[
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Container(),
              InboxMessageView(
                  messageId: widget.messageId,
                  onLoadStarted: handleLoadStarted,
                  onLoadFinished: handleLoadFinished,
                  onLoadError: handleLoadError,
                  onClose: handleClose)
            ]),
          );
        });
  }

  onStarted() {
    setState(() {
      isLoading = true;
    });
  }

  handleLoadStarted() {
    setState(() {
      isLoading = true;
    });
  }

  handleLoadFinished() {
    setState(() {
      isLoading = false;
    });
  }

  handleLoadError(PlatformException e) {
    setState(() {
      isLoading = false;
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
                e.message != null ? e.message! : "Unable to load message"),
            content: Text(e.details != null ? e.details : ""),
          ));
    });
  }

  handleClose() {
    setState(() {
      isLoading = false;
    });
  }
}