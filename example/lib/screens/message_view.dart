import 'package:flutter/material.dart';
import 'package:airship/airship.dart';
import 'package:airship_example/styles.dart';

class MessageView extends StatefulWidget {
  final InboxMessage message;

  MessageView({this.message});

  @override
  _MessageViewState createState() => _MessageViewState();
}

class _MessageViewState extends State<MessageView>  {
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: isLoading ?  Text("Loading...") : Text("${widget.message.title}"),

          backgroundColor: Styles.background,
        ),
        body: Stack(
              children: <Widget>[isLoading ? Center(child:CircularProgressIndicator()) : Container(), InboxMessageView(message: widget.message,
                onLoadStarted: onStarted,
                onLoadFinished: onLoadFinished)
        ]),
    );
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