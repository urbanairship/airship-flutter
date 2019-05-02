import 'dart:async';

import 'package:airship/airship.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _channelId = '';
  bool _notificationsEnabled = false;
  List<String> _tags = List(0);
  List<InboxMessage> _messages = List(0);

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    await Airship.addTags(["flutter"]);

    String channelId = await Airship.channelId;
    bool notificationsEnabled = await Airship.userNotificationsEnabled;
    List<String> tags = await Airship.tags;
    List<InboxMessage> messages = await Airship.inboxMessages;

    Airship.onPushReceived
        .listen((event) => debugPrint('Push Received $event'));

    Airship.onChannelUpdated
        .listen((event) => debugPrint('Channel Updated $event'));

    Airship.onChannelCreated.listen((channelId) {
      debugPrint('Channel Created $channelId');
      setState(() {
        _channelId = channelId;
      });
    });

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _channelId = channelId;
      _notificationsEnabled = notificationsEnabled;
      _tags = tags;
      _messages = messages;
    });
  }

  void onInboxMessageViewCreated(InboxMessageViewController controller) {
    if (_messages.length > 0) {
      controller.loadMessage(_messages[0]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body:  Container(
          child: InboxMessageView(onViewCreated: onInboxMessageViewCreated),
          height: 300.0,
        )
      ),
    );
  }
}
