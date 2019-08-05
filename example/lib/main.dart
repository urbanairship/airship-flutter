import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:airship_example/data/app_state.dart';
import 'package:airship_example/styles.dart';

import 'package:flutter/services.dart' show DeviceOrientation, SystemChrome;

import 'package:airship_example/screens/home.dart';
import 'package:airship_example/screens/settings.dart';
import 'package:airship_example/screens/message_center.dart';

void main() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    ScopedModel<AppState>(
      model: AppState(),
      child: MyApp(),
      ),
  );
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
    AppState.addFlutterTag();
  }

  @override
  Widget build(BuildContext context) {
    final model = ScopedModel.of<AppState>(context, rebuildOnChange: true);
    model.initPlatformState();

    return MaterialApp(
      home: Scaffold(
        body: TabBarView(
          children: <Widget>[Home(model:model), MessageCenter(model:model), Settings()],
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
