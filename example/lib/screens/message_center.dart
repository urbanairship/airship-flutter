import 'package:flutter/material.dart';
import 'package:airship_flutter/airship_flutter.dart';
import 'package:airship_example/styles.dart';
import 'package:airship_example/screens/message_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MessageCenter extends StatefulWidget {
  @override
  _MessageCenterState createState() => _MessageCenterState();
}

class _MessageCenterState extends State<MessageCenter> {
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    initAirshipListeners();
    Airship.trackScreen('Message Center');
    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initAirshipListeners() async {
    Airship.onInboxUpdated.listen((event) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _onRefresh() async{
    await Airship.refreshInbox();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildMessageList(List<InboxMessage> messages) {
      return SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        header: MaterialClassicHeader(),
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: ListView.builder(
          itemCount: messages != null ? messages.length : 0,
          itemBuilder: (context, index) {
            var message = messages[index];

            return Dismissible(
              key: Key(UniqueKey().toString()),
              background: Container(color: Styles.airshipRed),
              onDismissed: (direction) {
                ScaffoldMessenger
                    .of(context)
                    .showSnackBar(SnackBar(content: Text("Message \"${message.messageId}\" removed")));
                messages.remove(message);
                Airship.deleteInboxMessage(message);
                setState(() {});
              },
              // Add stream to check isRead
              child: ListTile(
                title: message.isRead ? Text('${message.title}') : Text('${message.title}', style:TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${message.sentDate}'),
                leading: Icon(message.isRead ? Icons.check_circle: Icons.markunread),
                onTap: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MessageView(messageId: message.messageId,)));
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
    );
  }

  updateState() {
    setState(() {});
  }
}