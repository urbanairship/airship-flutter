import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:airship_example/data/app_state.dart';
import 'package:airship_example/styles.dart';

class Home extends StatelessWidget {
  final AppState model;

  Home({this.model});

  @override
  Widget build(BuildContext context) {

    return ScopedModel(
      model: model,
      child: Scaffold(
        backgroundColor: Styles.background,
        body: Center (
          child:Container(
            alignment: Alignment.center,
            child:Wrap(
                children: <Widget>[ Image.asset(
                  'assets/airship.png',
                ),
                  Center(
                    child: FutureBuilder(
                      future: model.notificationsEnabled,
                      builder: (context, snapshot) {
                        Center enableNotificationsButton;
                        bool pushEnabled = snapshot.data ?? false;

                        enableNotificationsButton = Center (child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[ Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: MaterialButton(
                              child: Text( "Enable Push",
                                style: Styles.homeButtonText,
                              ),
                              color: Styles.airshipRed,
                              shape: StadiumBorder(),
                              height: 40,
                              minWidth: 400,
                              padding: EdgeInsets.symmetric(vertical: 35),
                              onPressed: () {
                                model.setUserNotificationsEnabled(true);
                              },),
                          )],
                        )
                        );

                        return Visibility(
                            visible:!pushEnabled,
                            child:enableNotificationsButton);
                      },
                    ),
                  ),
                  Center(
                    child: FutureBuilder(
                      future: model.channelId,
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
        ),
      ),
    );
  }
}