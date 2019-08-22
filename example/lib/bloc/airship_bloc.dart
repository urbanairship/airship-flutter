import 'dart:async';
import 'package:airship_example/bloc/bloc_base.dart';
import 'package:airship/airship.dart';
import 'package:flutter/material.dart';

class AirshipBloc implements BlocBase {
  final _channelStreamController = StreamController<String>();
  final _channelUpdatedStreamController = StreamController<String>();

  final _namedUserStreamController = StreamController<String>.broadcast();
  final _namedUserSetStreamController = StreamController<String>();

  final _notificationsEnabledStreamController = StreamController<bool>.broadcast();
  final _notificationsEnabledSetStreamController = StreamController<bool>();

  final _tagsStreamController = StreamController<List<String>>.broadcast();
  final _tagsAddedStreamController = StreamController<List<String>>();
  final _tagsRemovedStreamController = StreamController<List<String>>();

  final _messagesStreamController = StreamController<List<InboxMessage>>.broadcast();
  final _messageAddedStreamController = StreamController<InboxMessage>();
  final _messageRemovedStreamController = StreamController<InboxMessage>();

  Stream<String> get channelStream => _channelStreamController.stream;
  StreamSink<String> get channelSink => _channelStreamController.sink;

  Stream<String> get namedUserStream => _namedUserStreamController.stream;
  StreamSink<String> get namedUserSink=> _namedUserStreamController.sink;
  StreamSink<String> get namedUserSetSink => _namedUserSetStreamController.sink;

  Stream<bool> get notificationsEnabledStream => _notificationsEnabledStreamController.stream;
  StreamSink<bool> get notificationsEnabledSink => _notificationsEnabledStreamController.sink;
  StreamSink<bool> get notificationsEnabledSetSink => _notificationsEnabledSetStreamController.sink;

  Stream<List<String>> get tagsStream => _tagsStreamController.stream;
  StreamSink<List<String>> get tagsSink => _tagsStreamController.sink;

  Stream<List<InboxMessage>> get messagesStream => _messagesStreamController.stream;
  StreamSink<List<InboxMessage>> get messagesSink => _messagesStreamController.sink;

  StreamSink<List<String>> get tagsAddedSink => _tagsAddedStreamController.sink;
  StreamSink<List<String>> get tagsRemovedSink => _tagsRemovedStreamController.sink;

  StreamSink<InboxMessage> get messageRemovedSink => _messageRemovedStreamController.sink;

  AirshipBloc() {
    Airship.channelId.then((val) {
      _channelStreamController.add(val);
    });

    Airship.tags.then((val) {
      _tagsStreamController.add(val);
    });

    _tagsAddedStreamController.stream.listen((tags) {
      Airship.addTags(tags).then((val) {
        // Add the tags then grab fresh tags list
        Airship.tags.then((airshipTags) {
          tagsSink.add(airshipTags);
        });
      });
    });

    _tagsRemovedStreamController.stream.listen((tags) {
      Airship.removeTags(tags).then((val) {
        // Remove the tags then grab fresh tags list
        Airship.tags.then((airshipTags) {
          tagsSink.add(airshipTags);
        });
      });
    });

    Airship.namedUser.then((val) {
      _namedUserStreamController.add(val);
    });

    _namedUserSetStreamController.stream.listen((namedUser) {
      Airship.setNamedUser(namedUser).then((val) {
        namedUserSink.add(namedUser);
      });
    });

    Airship.userNotificationsEnabled.then((val) {
      _notificationsEnabledStreamController.add(val);
    });

    _notificationsEnabledSetStreamController.stream.listen((enabled) {
      Airship.setUserNotificationsEnabled(enabled).then((val) {
        notificationsEnabledSink.add(val);
      });
    });

    Airship.inboxMessages.then((messages) {
      _messagesStreamController.add(messages);
    });

    _messageAddedStreamController.stream.listen((messages) {
      Airship.inboxMessages.then((messages) {
        messagesSink.add(messages);
      });
    });

    _messageRemovedStreamController.stream.listen((message) {
      Airship.deleteInboxMessage(message).then((onValue) {
        // Get fresh message list
        Airship.inboxMessages.then((messages) {
          messagesSink.add(messages);
        });
      });
    });

    Airship.onInboxUpdated.listen((event) {
      debugPrint('Inbox updated link');
      // Get fresh message list
      Airship.inboxMessages.then((messages) {
        messagesSink.add(messages);
      });
    });

    Airship.onShowInboxMessage.listen((messageId) {
      //MaterialPageRoute(builder: (context) => MessageView(message: message));
      debugPrint('Show inbox message $messageId');
      Airship.inboxMessages.then((messages) {
        messagesSink.add(messages);
      });
    });

    Airship.onChannelRegistration.listen((event) {
      _channelUpdatedStreamController.add(event.channelId);
      debugPrint('Channel registration $event');
    });

    Airship.onPushReceived.listen((event) {
      debugPrint('Push Received $event');
    });

    Airship.onNotificationResponse.listen((event) {
      debugPrint('Notification Response $event');
    });

    Airship.onDeepLink.listen((deepLink) {
      debugPrint('Deep link $deepLink');
    });

    Airship.onShowInbox.listen((event) {
      debugPrint('Show inbox');
    });
  }

  void dispose(){
    _channelStreamController.close();
  }
}

