import 'package:flutter/material.dart';
import 'package:airship_example/styles.dart';
import 'package:airship_example/widgets/notifications_enabled_button.dart';
// ignore: depend_on_referenced_packages
import 'package:airship_flutter/airship_flutter.dart';
import 'dart:io' show Platform;
import 'package:uuid/uuid.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
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

  Future<void> _startNewActivity() async {
    if (Platform.isIOS) {
      LiveActivityStartRequest startRequest = LiveActivityStartRequest(
          attributesType: 'ExampleWidgetsAttributes',
          attributes: {
            "name": Uuid().v4(),
          },
          content:
              LiveActivityContent(state: {'emoji': '🙌'}, relevanceScore: 0.0));

      await Airship.liveActivityManager.start(startRequest);
    } else if (Platform.isAndroid) {
      LiveUpdateStartRequest createRequest = LiveUpdateStartRequest(
        name: "Cool",
        type: 'Example',
        content: {'emoji': '🙌'},
      );

      await Airship.liveUpdateManager.start(createRequest);
    }
  }

  Future<void> _stopAllActivities() async {
    if (Platform.isIOS) {
      List<LiveActivity> activities =
          await Airship.liveActivityManager.listAll();
      for (var activity in activities) {
        LiveActivityStopRequest stopRequest = LiveActivityStopRequest(
          attributesType: 'ExampleWidgetsAttributes',
          activityId: activity.id,
          dismissalPolicy: LiveActivityDismissalPolicyImmediate(),
        );

        await Airship.liveActivityManager.end(stopRequest);
      }
    } else if (Platform.isAndroid) {
      List<LiveUpdate> updates = await Airship.liveUpdateManager.listAll();
      for (var update in updates) {
        LiveUpdateEndRequest stopRequest =
            LiveUpdateEndRequest(name: update.name);
        await Airship.liveUpdateManager.end(stopRequest);
      }
    }
  }

  Future<void> _updateAllActivities() async {
    if (Platform.isIOS) {
      List<LiveActivity> activities =
          await Airship.liveActivityManager.listAll();
      for (var activity in activities) {
        LiveActivityContent content =
            LiveActivityContent(state: {'emoji': '🙌'}, relevanceScore: 0.0);

        LiveActivityUpdateRequest updateRequest = LiveActivityUpdateRequest(
          attributesType: 'ExampleWidgetsAttributes',
          activityId: activity.id,
          content: content,
        );

        await Airship.liveActivityManager.update(updateRequest);
      }
    } else if (Platform.isAndroid) {
      List<LiveUpdate> updates = await Airship.liveUpdateManager.listAll();

      for (var update in updates) {
        var currentEmoji = update.content['emoji'] ?? '';

        LiveUpdateUpdateRequest request = LiveUpdateUpdateRequest(
          name: update.name,
          content: {
            'emoji': currentEmoji == '🙌' ? '👍' : '🙌',
          },
        );

        await Airship.liveUpdateManager.update(request);
      }
    }
  }

  Widget _buildTableRow(
      String label, String buttonText, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(5), // Slightly lighter than the background
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16), // Offset label by 16 points
            child: Text(
              label,
              style: TextStyle(color: Colors.white),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                right: 16), // Padding button 16 points from the right
            child: SizedBox(
              width: 100, // Fixed button width for uniform size
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Styles.airshipBlue.withAlpha(80),
                ),
                child: Text(buttonText),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Styles.background,
        body: Center(
          child: Container(
            alignment: Alignment.center,
            child: Wrap(children: <Widget>[
              Center(
                  child: AirshipEmbeddedView(
                      embeddedId: "test", parentHeight: 200)),
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
                        Airship.push.enableUserNotifications(
                            options: EnableUserPushNotificationsArgs(
                          fallback: PromptPermissionFallback.systemSettings,
                        ));

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
              SizedBox(height: 36),
              Center(
                child: Card(
                  color: Colors.grey.withAlpha(15),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Platform.isIOS ? 'Live Activities' : 'Live Updates',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 12),
                        Column(
                          children: [
                            _buildTableRow(
                                'Start New', 'Start', _startNewActivity),
                            _buildTableRow(
                                'End All', 'End', _stopAllActivities),
                            _buildTableRow(
                                'Update All', 'Update', _updateAllActivities),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ));
  }
}
