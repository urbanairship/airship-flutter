import 'package:flutter/material.dart';
import 'package:airship_example/styles.dart';

import 'package:flutter/services.dart' show DeviceOrientation, SystemChrome;

import 'package:airship_example/screens/home.dart';
import 'package:airship_example/screens/settings.dart';
import 'package:airship_example/screens/message_center.dart';
import 'package:airship/airship.dart';

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

    addFlutterTag();
  }

  static void addFlutterTag() {
    Airship.addTags(["flutter"]);
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
