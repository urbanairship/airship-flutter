import 'package:flutter/material.dart';
import 'package:airship_example/styles.dart';
import 'package:airship_example/widgets/notifications_enabled_button.dart';
import 'package:airship_flutter/airship_flutter.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    initAirshipListeners();
    Airship.analytics.trackScreen('Home');

    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initAirshipListeners() async {
    Airship.channel.onChannelCreated.listen((event) {
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
            Container(
                width: 420,
                height: 420,
                child: Center(
                  child: EmbeddedView(embeddedId: "test"),
                ),
              ),
              Image.asset(
                'assets/airship.png',
              ),
              Center(
                child: FutureBuilder<bool?>(
                  future: Airship.push.isUserNotificationsEnabled,
                  builder: (context, AsyncSnapshot<bool?> snapshot) {
                    Center enableNotificationsButton;
                    bool pushEnabled = snapshot.data ?? false;
                    enableNotificationsButton =
                        Center(child: NotificationsEnabledButton(
                      onPressed: () {
                        Airship.push.setUserNotificationsEnabled(true);
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
                  future: Airship.channel.identifier,
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
