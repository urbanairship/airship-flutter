import 'package:flutter/foundation.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:airship_example/screens/message_view.dart';

import 'package:airship/airship.dart';
class AppState extends Model {
  Future<String> channelId = Airship.channelId;
  Future<String> namedUser = Airship.namedUser;
  Future<bool> notificationsEnabled = Airship.userNotificationsEnabled;
  Future<List<String>> tags = Airship.tags;
  Future<List<InboxMessage>> messages = Airship.inboxMessages;

  void setUserNotificationsEnabled(bool enabled) {
    Airship.setUserNotificationsEnabled(enabled);
    Airship.userNotificationsEnabled.then((isEnabled) {
      notificationsEnabled = Future(() {
        notifyListeners();
        return isEnabled;
      });
    });
    notifyListeners();
  }

  static void addFlutterTag() {
    Airship.addTags(["flutter"]);
  }

  void addTag(String tag) {
    Airship.addTags([tag]).then((val){
      notifyListeners();
      return val;
    });
  }

  void removeTag(String tag) async {
    await Airship.removeTags([tag]).then((val){
      notifyListeners();
      return val;
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    Airship.onPushReceived.listen((event){
      debugPrint('Push Received $event');
      notifyListeners();
    });

    Airship.onNotificationResponse.listen((event) {
      debugPrint('Notification Response $event');
      notifyListeners();
    });

    Airship.onDeepLink.listen((deepLink) {
      debugPrint('Deep link $deepLink');
      notifyListeners();
    });

    Airship.onInboxUpdated.listen((event){
      debugPrint('Inbox updated link');
      notifyListeners();
    });

    Airship.onShowInbox.listen((event) {
      debugPrint('Show inbox');
      notifyListeners();
    });

    Airship.onShowInboxMessage.listen((messageId) {
      //MaterialPageRoute(builder: (context) => MessageView(message: message));
      debugPrint('Show inbox message $messageId');
      notifyListeners();
    });

    Airship.onChannelRegistration.listen((event) {
      channelId = Future(() {
          notifyListeners();
          return event.channelId;
      });
      debugPrint('Channel registration $event');
    });
  }
}
