import 'package:flutter/material.dart';
import 'package:airship/airship.dart';
import 'package:airship_example/styles.dart';
import 'package:airship_example/screens/message_view.dart';
import 'package:airship_example/bloc/bloc.dart';

class MessageCenter extends StatelessWidget {
  final AirshipBloc _airshipBloc = AirshipBloc();

  @override
  Widget build(BuildContext context) {
    Widget _buildMessageList(List<InboxMessage> messages) {
      //messages = List<InboxMessage>.from(messages);

      return ListView.builder(
        itemCount: messages != null ? messages.length : 0,
        itemBuilder: (context, index) {
          var message = messages[index];

          return Dismissible(
            key: Key(UniqueKey().toString()),
            background: Container(color: Styles.airshipRed),
            onDismissed: (direction) {
              Scaffold
                  .of(context)
                  .showSnackBar(SnackBar(content: Text("Message \"${message.messageId}\" removed")));
              messages.remove(message);
              _airshipBloc.messageRemovedSink.add(message);
            },
            // Add stream to check isRead
            child: ListTile(
              title: message.isRead ? Text('${message.title}') : Text('${message.title}', style:TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${message.sentDate}'),
              leading: Icon(message.isRead ? Icons.markunread : Icons.check_circle) ,
              onTap: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MessageView(message: message)));
              },
            ),
          );
        },
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Message Center'),
          backgroundColor: Styles.borders,
        ),
        body: StreamBuilder(
          stream: _airshipBloc.messagesStream,
          builder: (context, snapshot) {
            List<InboxMessage> list = [];

            if (snapshot.hasData) {
              list = List<InboxMessage>.from(snapshot.data);
            }

            return SafeArea(
              bottom: false,
              child: Column(
                children: <Widget>[
                  Expanded(
                      child: _buildMessageList(list)
                  ),
                ],
              ),
            );
          },
        )
    );
  }
}

void onInboxMessageViewCreated(InboxMessageViewController controller) {
  Airship.inboxMessages.then((List<InboxMessage> messages) {
    if (messages.length > 0) {
      debugPrint("Loading message: ${messages[0].messageId}");
      controller.loadMessage(messages[0]);
    } else {
      debugPrint("Error message: $messages");
    }
  });
}