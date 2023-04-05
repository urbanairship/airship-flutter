import 'package:flutter/material.dart' hide Notification;
import 'package:airship_example/styles.dart';

import 'package:flutter/services.dart' show DeviceOrientation, SystemChrome;

import 'package:airship_example/screens/home.dart';
import 'package:airship_example/screens/settings.dart';
import 'package:airship_example/screens/message_center.dart';
import 'package:airship_example/screens/message_view.dart';
import 'package:airship_example/screens/preference_center.dart';
import 'dart:developer';
import 'package:airship_flutter/airship_flutter.dart';

// Supported deep links
const String home_deep_link = "home";
const String message_center_deep_link = "message_center";
const String settings_deep_link = "settings";
//
// Future<void> backgroundMessageHandler(
//     Map<String, dynamic> payload, Notification? notification) async {
//   print("Background Push Received $payload, $notification");
// }

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  var configEnvironment = ConfigEnvironment("YOUR_APP_KEY", "YOUR_APP_SECRET");
  var config = AirshipConfig(configEnvironment);
  Airship.takeOff(config);
  // Airship.setBackgroundMessageHandler(backgroundMessageHandler);

  Airship.contact.identify("FlutterUser");

  Airship.channel.editSubscriptionLists()
  ..subscribe("foo")
  ..unsubscribe("bar")
  ..apply();

  Airship.analytics.trackScreen("bigScreen");

  var list = <String>[];
  list.add("contact");

  var map = Map<String, ChannelScope>();
  map.addAll({
    "contact" : ChannelScope.app
  });

  Airship.contact.editSubscriptionLists()
  ..subscribe("cat_facts", ChannelScope.app.getStringValue())
  ..apply();
  
  var customEvent = new CustomEvent("test_event", 77);
  Airship.analytics.addEvent(customEvent);

  Airship.push.getRegistrationToken().then((value) => log("SampleTest token : " + value!));

  Airship.contact.getSubscriptionLists(map).then((value) => log("SampleTest lists : " + value.toString()));


  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

// SingleTickerProviderStateMixin is used for animation
class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  late TabController controller;

  final GlobalKey<NavigatorState> key = GlobalKey();

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 4, vsync: this);
    initPlatformState();
    addFlutterTag();

    // Uncomment to enable Hybrid Composition on Android
    // InboxMessageView.hybridComposition = true;
  }

  static void addFlutterTag() {
    // Airship.addTags(["flutter"]);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Airship.onPushReceived.listen((event) {
    //   debugPrint('Push Received $event');
    // });
    //
    // Airship.onNotificationResponse
    //     .listen((event) => debugPrint('Notification Response $event'));
    //
    // Airship.onDeepLink.listen((event) {
    //   const home_tab = 0;
    //   const message_tab = 1;
    //   const settings_tab = 2;
    //
    //   switch (event) {
    //     case home_deep_link:
    //       {
    //         controller.animateTo(home_tab);
    //         break;
    //       }
    //     case message_center_deep_link:
    //       {
    //         controller.animateTo(message_tab);
    //         break;
    //       }
    //     case settings_deep_link:
    //       {
    //         controller.animateTo(settings_tab);
    //         break;
    //       }
    //   }
    // });
    //
    // Airship.onInboxUpdated?.listen((event) => debugPrint('Inbox updated link'));
    //
    // Airship.onShowInbox?.listen((event) => debugPrint('Show inbox'));
    //
    // Airship.onShowInboxMessage.listen((messageId) {
    //   key.currentState
    //       ?.push(MaterialPageRoute<Null>(builder: (BuildContext context) {
    //     return messageId != null
    //         ? MessageView(
    //             messageId: messageId,
    //           )
    //         : SizedBox();
    //   }));
    // });
    //
    Airship.channel.onChannelCreated.listen((event) {
      debugPrint('Channel created $event');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: key,
      title: "Airship Sample App",
      initialRoute: "/",
      routes: {
        '/': (context) => tabBarView(),
      },
    );
  }

  Widget tabBarView() {
    return WillPopScope(
        onWillPop: null,
        child: Scaffold(
          body: TabBarView(
            children: <Widget>[
              Home(),
              Home(),
              Home(),
              Home()
            ],
            controller: controller,
          ),
          bottomNavigationBar: bottomNavigationBar(),
        ));
  }

  Widget bottomNavigationBar() {
    return Material(
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
            icon: Icon(Icons.menu),
          ),
          Tab(
            icon: Icon(Icons.settings),
          ),
        ],
        // setup the controller
        controller: controller,
      ),
    );
  }
}
