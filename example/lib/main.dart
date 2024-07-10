import 'package:airship_example/screens/message_center.dart';
import 'package:airship_example/screens/message_view.dart';
import 'package:airship_example/screens/preference_center.dart';
import 'package:airship_example/screens/settings.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:airship_example/styles.dart';

import 'package:flutter/services.dart' show DeviceOrientation, SystemChrome;

import 'package:airship_example/screens/home.dart';
import 'package:airship_flutter/airship_flutter.dart';

// Supported deep links
const String home_deep_link = "home";
const String message_center_deep_link = "message_center";
const String settings_deep_link = "settings";

@pragma('vm:entry-point')
Future<void> backgroundMessageHandler(PushReceivedEvent event) async {
  debugPrint("Background Push Received $event");
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  var config = AirshipConfig(
    defaultEnvironment: ConfigEnvironment(
        appKey: "APP_KEY",
        appSecret: "APP_SECRET",
        ios: IOSEnvironment(logPrivacyLevel: LogPrivacyLevel.public)),
  );

  Airship.takeOff(config);
  Airship.push.android
      .setBackgroundPushReceivedHandler(backgroundMessageHandler);

  Airship.push.iOS.setForegroundPresentationOptions([
    IOSForegroundPresentationOption.banner,
    IOSForegroundPresentationOption.list
  ]);
  Airship.contact.identify("FlutterUser");

  Airship.messageCenter.setAutoLaunchDefaultMessageCenter(false);
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
    trackFeatureFlagInteraction();

    // Uncomment to enable Hybrid Composition on Android
    // InboxMessageView.hybridComposition = true;
  }

  static void trackFeatureFlagInteraction() {
    Airship.featureFlagManager.flag("rad_flag").then((flag) {
      Airship.featureFlagManager.trackInteraction(flag);
    }).catchError((e) {
      debugPrint('Error: $e');
    });
  }

  static void addFlutterTag() {
    Airship.channel.addTags(["flutter"]);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    Airship.push.onPushReceived.listen((event) {
      debugPrint('Push Received $event');
    });

    Airship.push.onNotificationResponse.listen((event) {
      debugPrint('Notification Response $event');
    });

    Airship.push.onPushTokenReceived.listen((event) {
      debugPrint('Push token received $event');
    });

    Airship.push.onNotificationStatusChanged.listen((event) {
      debugPrint('Notification status changed $event');
    });

    Airship.push.iOS.onAuthorizedSettingsChanged.listen((event) {
      debugPrint('Authorized settings changed $event');
    });

    Airship.push.iOS.authorizedNotificationSettings
        .then((value) => debugPrint("authorizedNotificationSettings $value"));
    Airship.push.iOS.authorizedNotificationStatus
        .then((value) => debugPrint("authorizedNotificationStatus $value"));

    Airship.onDeepLink.listen((event) {
      const home_tab = 0;
      const message_tab = 1;
      const settings_tab = 2;

      switch (event.deepLink) {
        case home_deep_link:
          {
            controller.animateTo(home_tab);
            break;
          }
        case message_center_deep_link:
          {
            controller.animateTo(message_tab);
            break;
          }
        case settings_deep_link:
          {
            controller.animateTo(settings_tab);
            break;
          }
      }
    });

    Airship.messageCenter.onInboxUpdated
        .listen((event) => debugPrint('Inbox updated $event'));

    Airship.messageCenter.onDisplay
        .listen((event) => debugPrint('Show inbox $event'));

    Airship.messageCenter.onDisplay.listen((event) {
      key.currentState
          ?.push(MaterialPageRoute<Null>(builder: (BuildContext context) {
        return event.messageId != null
            ? MessageView(
                messageId: event.messageId ?? "",
              )
            : SizedBox();
      }));
    });

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
      theme: ThemeData(
        primaryColor: Styles.borders,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Styles.airshipBlue, // Set the accent color to airshipBlue
        ),
        switchTheme: SwitchThemeData(
          trackColor:
              WidgetStateProperty.all(Styles.airshipBlue), // Set track color
        ),
      ),
      initialRoute: "/",
      routes: {
        '/': (context) => tabBarView(),
      },
    );
  }

  Widget bottomNavigationBar() {
    return Container(
      color: Styles.borders, // Set the same color as the tab bar
      child: SafeArea(
        bottom: true,
        child: Material(
          color: Colors.transparent,
          child: Container(
            color: Styles.borders,
            child: TabBar(
              indicatorColor: Styles.airshipRed,
              unselectedLabelColor: Colors.grey, // Set unselected label color
              labelColor:
                  Styles.airshipBlue, // Set selected label color to airshipBlue
              tabs: <Tab>[
                Tab(
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
              controller: controller,
            ),
          ),
        ),
      ),
    );
  }

  Widget tabBarView() {
    return PopScope(
      onPopInvoked: null,
      child: Scaffold(
        backgroundColor: Styles.borders,
        body: TabBarView(
          children: <Widget>[
            Home(),
            MessageCenter(),
            PreferenceCenter(),
            Settings()
          ],
          controller: controller,
        ),
        bottomNavigationBar: bottomNavigationBar(),
      ),
    );
  }
}
