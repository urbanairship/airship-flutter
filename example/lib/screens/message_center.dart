import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:airship_flutter/airship_flutter.dart';
import 'package:airship_example/styles.dart';
import 'package:airship_example/screens/message_view.dart';

class MessageCenter extends StatefulWidget {
  const MessageCenter({super.key});

  @override
  MessageCenterState createState() => MessageCenterState();
}

class MessageCenterState extends State<MessageCenter> {
  @override
  void initState() {
    initAirshipListeners();
    Airship.analytics.trackScreen('Message Center');
    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initAirshipListeners() async {
    Airship.messageCenter.onInboxUpdated.listen((event) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<bool?> _onRefresh() async {
    return await Airship.messageCenter.refreshInbox();
  }

  @override
  Widget build(BuildContext context) {
    Widget buildMessageList(final List<InboxMessage> messages) {
      return RefreshIndicator(
        strokeWidth: 1,
        displacement: 50,
        onRefresh: _onRefresh,
        child: ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            InboxMessage message = messages[index];

            return Dismissible(
              key: Key(UniqueKey().toString()),
              background: Container(color: Styles.airshipRed),
              onDismissed: (direction) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Message \"${message.messageId}\" removed")));
                messages.remove(message);
                Airship.messageCenter.deleteMessage(message.messageId);
                setState(() {});
              },
              // Add stream to check isRead
              child: ListTile(
                title: message.isRead
                    ? Text(message.title)
                    : Text(message.title,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${message.sentDate}'),
                leading: Icon(
                    message.isRead ? Icons.check_circle : Icons.markunread),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MessageView(
                                messageId: message.messageId,
                              )));
                },
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Message Center'),
          backgroundColor: Styles.borders,
        ),
        body: FutureBuilder<List<InboxMessage>>(
          future: Airship.messageCenter.messages,
          builder: (context, snapshot) {
            List<InboxMessage> list = [];

            if (snapshot.hasData) {
              list = snapshot.data!;
            }

            return SafeArea(
              bottom: false,
              child: Column(
                children: <Widget>[
                  Expanded(child: buildMessageList(list)),
                ],
              ),
            );
          },
        ));
  }

  updateState() {
    setState(() {});
  }
}
