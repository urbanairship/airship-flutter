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
  List<String> _tags;
  List<InboxMessage> _messages;

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Wrap(children: <Widget>[
          Row(children: <Widget>[
            Text("Channel ID: $_channelId"),
          ]),
          Row(children: <Widget>[
            Text("Enable Notitificaitons"),
            Checkbox(
                value: _notificationsEnabled,
                onChanged: (value) {
                  Airship.setUserNotificationsEnabled(value);
                  setState(() {
                    _notificationsEnabled = value;
                  });
                }),
          ]),
          Row(children: <Widget>[
            Wrap(children: <Widget>[
              Text("Tags"),
              Container(
                margin: const EdgeInsets.all(10.0),
                width: 100.0,
                height: 100.0,
                child: ListView.builder(
                  itemCount: _tags.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('${_tags[index]}'),
                    );
                  },
                ),
              ),
            ])
          ]),
          Row(children: <Widget>[
            Wrap(children: <Widget>[
              Text("Messages"),
              Container(
                margin: const EdgeInsets.all(10.0),
                width: 300,
                height: 100.0,
                child: ListView.builder(
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('${_messages[index].title} ${_messages[index].messageId}'),
                    );
                  },
                ),
              ),
            ])
          ]),
        ]),
      ),
    );
  }
}
