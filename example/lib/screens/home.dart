import 'package:flutter/material.dart';
import 'package:airship_example/styles.dart';
import 'package:airship_example/widgets/notifications_enabled_button.dart';
import 'package:airship_flutter/airship_flutter.dart';

class Home extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  @override
  void initState() {
    initAirshipListeners();
    Airship.trackScreen('Home');

    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initAirshipListeners() async {
    Airship.onChannelRegistration.listen((event) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Styles.background,
        body: Center(
          child: Container(
            alignment: Alignment.center,
            child: Wrap(children: <Widget>[
              Image.asset(
                'assets/airship.png',
              ),
              Center(
                child: FutureBuilder<bool>(
                  future: Airship.userNotificationsEnabled,
                  builder: (context, AsyncSnapshot<bool> snapshot) {
                    Center enableNotificationsButton;
                    bool pushEnabled = snapshot.data ?? false;
                    enableNotificationsButton =
                        Center(child: NotificationsEnabledButton(
                      onPressed: () {
                        Airship.setUserNotificationsEnabled(true);
                        setState(() {});
                      },
                    ));
                    return Visibility(
                        visible: !pushEnabled,
                        child: enableNotificationsButton);
                  },
                ),
              ),
              Center(
                child: FutureBuilder(
                  future: Airship.channelId,
                  builder: (context, snapshot) {
                    return Text(
                      '${snapshot.hasData ? snapshot.data : "Channel not set"}',
                      textAlign: TextAlign.center,
                      style: Styles.homePrimaryText,
                    );
                  },
                ),
              ),
            ]),
          ),
        ));
  }
}
