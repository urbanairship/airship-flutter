import 'package:airship_example/screens/message_center.dart';
import 'package:airship_example/screens/message_view.dart';
import 'package:airship_example/screens/preference_center.dart';
import 'package:airship_example/screens/settings.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:airship_example/styles.dart';

import 'package:flutter/services.dart' show DeviceOrientation, SystemChrome;

import 'package:airship_example/screens/home.dart';
// ignore: depend_on_referenced_packages
import 'package:airship_flutter/airship_flutter.dart';

// Supported deep links
const String homeDeepLink = "home";
const String messageCenterDeepLink = "message_center";
const String settingsDeepLink = "settings";

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
    androidConfig: AndroidConfig(
      notificationConfig: AndroidNotificationConfig(
        icon: "ic_notification",
      ),
    ),
    defaultEnvironment: ConfigEnvironment(
      appKey: "",
      appSecret: "",
      logLevel: LogLevel.verbose,
      ios: IOSEnvironment(logPrivacyLevel: AirshipLogPrivacyLevel.public),
      android: AndroidEnvironment(logPrivacyLevel: AirshipLogPrivacyLevel.public),
    ),
  );

  Airship.takeOff(config);

  Airship.push.android.setBackgroundPushReceivedHandler(backgroundMessageHandler);

  Airship.push.iOS.setForegroundPresentationOptions([
    IOSForegroundPresentationOption.banner,
    IOSForegroundPresentationOption.list
  ]);
  Airship.contact.identify("FlutterUser");

  Airship.messageCenter.setAutoLaunchDefaultMessageCenter(false);
  runApp(const AirshipApp());
}

class AirshipApp extends StatefulWidget {
  const AirshipApp({super.key});

  @override
  State<AirshipApp> createState() => _AirshipAppState();
}

class _AirshipAppState extends State<AirshipApp> {
  final ThemeModeNotifier _themeModeNotifier = ThemeModeNotifier();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _themeModeNotifier,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Airship Sample App",
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _themeModeNotifier.themeMode,
          home: MainNavigator(themeModeNotifier: _themeModeNotifier),
        );
      },
    );
  }
}

class MainNavigator extends StatefulWidget {
  final ThemeModeNotifier themeModeNotifier;

  const MainNavigator({
    super.key,
    required this.themeModeNotifier,
  });

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _initPlatformState();
    _addFlutterTag();
    _trackFeatureFlagInteraction();
  }

  static void _trackFeatureFlagInteraction() {
    Airship.featureFlagManager.flag("rad_flag").then((flag) {
      if (flag != null) {
        Airship.featureFlagManager.trackInteraction(flag);
      }
    }).catchError((e) {
      debugPrint('Error: $e');
    });
  }

  static void _addFlutterTag() {
    Airship.channel.addTags(["flutter"]);
  }

  Future<void> _initPlatformState() async {
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
      switch (event.deepLink) {
        case homeDeepLink:
          setState(() => _currentIndex = 0);
          break;
        case messageCenterDeepLink:
          setState(() => _currentIndex = 1);
          break;
        case settingsDeepLink:
          setState(() => _currentIndex = 3);
          break;
      }
    });

    Airship.inApp.onEmbeddedInfoUpdated
        .listen((event) => debugPrint('Embedded info updated $event'));

    Airship.messageCenter.onInboxUpdated
        .listen((event) => debugPrint('Inbox updated $event'));

    Airship.messageCenter.onDisplay
        .listen((event) => debugPrint('Show inbox $event'));

    Airship.messageCenter.onDisplay.listen((event) {
      if (event.messageId != null) {
        _navigatorKey.currentState?.push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => MessageView(
              messageId: event.messageId!,
            ),
          ),
        );
      }
    });

    Airship.channel.onChannelCreated.listen((event) {
      debugPrint('Channel created $event');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navigatorKey,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => _MainScaffold(
            currentIndex: _currentIndex,
            onIndexChanged: (index) => setState(() => _currentIndex = index),
            themeModeNotifier: widget.themeModeNotifier,
          ),
        );
      },
    );
  }
}

class _MainScaffold extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final ThemeModeNotifier themeModeNotifier;

  const _MainScaffold({
    required this.currentIndex,
    required this.onIndexChanged,
    required this.themeModeNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [
          const Home(),
          const MessageCenter(),
          const PreferenceCenter(),
          Settings(themeModeNotifier: themeModeNotifier),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onIndexChanged,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        shadowColor: colorScheme.shadow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.inbox_outlined),
            selectedIcon: Icon(Icons.inbox),
            label: 'Messages',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune),
            label: 'Preferences',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
