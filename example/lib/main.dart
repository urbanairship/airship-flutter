import 'package:flutter/material.dart';
import 'package:airship_example/styles.dart';

import 'package:flutter/services.dart' show DeviceOrientation, SystemChrome;

import 'package:airship_example/screens/home.dart';
import 'package:airship_example/screens/settings.dart';
import 'package:airship_example/screens/message_center.dart';
import 'package:airship/airship.dart';

// Supported deep links
const String home_deep_link =  "home";
const String message_center_deep_link =  "message_center";
const String settings_deep_link =  "settings";

void main() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

// SingleTickerProviderStateMixin is used for animation
class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);
    initPlatformState();
    addFlutterTag();
  }

  static void addFlutterTag() {
    Airship.addTags(["flutter"]);
  }

// Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    Airship.onPushReceived.listen((event) {
      debugPrint('Push Received $event');
    });

    Airship.onNotificationResponse
        .listen((event) => debugPrint('Notification Response $event'));

    Airship.onDeepLink.listen((event){
      const home_tab =  0;
      const message_tab =  1;
      const settings_tab =  2;

      switch(event) {
        case home_deep_link: {
          controller.animateTo(home_tab);
          break;
        }
        case message_center_deep_link: {
          controller.animateTo(message_tab);
          break;
        }
        case settings_deep_link: {
          controller.animateTo(settings_tab);
          break;
        }
      }
    });

    Airship.onInboxUpdated
        .listen((event) => debugPrint('Inbox updated link'));

    Airship.onShowInbox
        .listen((event) => debugPrint('Show inbox'));

    Airship.onShowInboxMessage
        .listen((messageId) => debugPrint('Show inbox message $messageId'));

    Airship.onChannelRegistration.listen((event) {
      debugPrint('Channel registration $event');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Airship Sample App",
      home: Scaffold(
        body: TabBarView(
          children: <Widget>[Home(), MessageCenter(), Settings()],
          controller: controller,
        ),
        bottomNavigationBar: Material(
          // set the color of the bottom navigation bar
          color: Styles.borders,
          // set the tab bar as the child of bottom navigation bar
          child: TabBar(
            indicatorColor: Styles.airshipRed,
            tabs: <Tab>[
              Tab(
                // set icon to the tab
                icon: Icon(Icons.home),
              ),
              Tab(
                icon: Icon(Icons.inbox),
              ),
              Tab(
                icon: Icon(Icons.settings),
              ),
            ],
            // setup the controller
            controller: controller,
          ),
        ),
      ),
    );
  }
}
