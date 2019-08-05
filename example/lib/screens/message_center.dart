import 'package:flutter/material.dart';
import 'package:airship/airship.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:airship_example/data/app_state.dart';
import 'package:airship_example/styles.dart';
import 'package:airship_example/screens/message_view.dart';

class MessageCenter extends StatelessWidget {
  final AppState model;

  MessageCenter({this.model});

  @override
  Widget build(BuildContext context) {
    Widget _buildMessageList(List<InboxMessage> messages) {
      messages = List<InboxMessage>.from(messages);

      return ScopedModel(
          model: model,
          child: ListView.builder(
            itemCount: messages != null ? messages.length : 0,
            itemBuilder: (context, index) {
              var message = messages[index];

              return Dismissible(
                key: Key(UniqueKey().toString()),
                background: Container(color: Styles.airshipRed),
                onDismissed: (direction) {
                  Scaffold
                      .of(context)
                      .showSnackBar(SnackBar(content: Text("Message \"$message\" removed")));
                  messages.remove(message);

                  Airship.deleteInboxMessage(message);
                },
                child: ListTile(
                  title: message.isRead ? Text('${message.title}') : Text('${message.title}', style:TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${message.sentDate}'),
                  leading: Icon(message.isRead ? Icons.markunread : Icons.check_circle) ,
                  onTap: (){
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MessageView(message: message,)));
                  },
                ),
              );
            },
          ));
    }

    return ScopedModel(
        model: model,
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Message Center'),
              backgroundColor: Styles.borders,
            ),
            body: FutureBuilder(
              future: Airship.inboxMessages,
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