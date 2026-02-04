import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:airship_flutter/airship_flutter.dart';
import 'package:airship_example/styles.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';

class MessageView extends StatefulWidget {
  final String messageId;

  const MessageView({super.key, required this.messageId});

  @override
  MessageViewState createState() => MessageViewState();
}

class MessageViewState extends State<MessageView> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Airship.analytics.trackScreen('Message View');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<InboxMessage>>(
      future: Airship.messageCenter.messages,
      builder: (context, snapshot) {
        final messages = snapshot.data ?? [];
        
        final message = messages.firstWhereOrNull(
          (thisMessage) => widget.messageId == thisMessage.messageId,
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(
              message?.title ?? 'Message',
              overflow: TextOverflow.ellipsis,
            ),
            backgroundColor: Styles.background,
            elevation: 0,
          ),
          backgroundColor: Styles.background,
          body: Stack(
            children: [
              InboxMessageView(
                messageId: widget.messageId,
                onLoadStarted: _handleLoadStarted,
                onLoadFinished: _handleLoadFinished,
                onLoadError: _handleLoadError,
                onClose: _handleClose,
              ),
              if (_isLoading)
                Container(
                  color: Colors.black45,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _handleLoadStarted() {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
  }

  void _handleLoadFinished() {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleLoadError(PlatformException e) {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(e.message ?? "Unable to load message"),
          content: Text(e.details ?? "An error occurred while loading the message."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _handleClose() {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    }
  }
}
