import 'package:flutter/material.dart';
import 'package:airship_example/styles.dart';
import 'package:airship_example/bloc/airship_bloc.dart';

class _HomeState extends State<Home> {
  final AirshipBloc _airshipBloc = AirshipBloc();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Styles.background,
        body: Center (
          child:Container(
            alignment: Alignment.center,
            child:Wrap(
                children: <Widget>[ Image.asset(
                  'assets/airship.png',
                ),
                  Center(
                    child: StreamBuilder(
                      stream: _airshipBloc.notificationsEnabledStream,
                      builder: (context, AsyncSnapshot<bool> snapshot) {
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
                                // TODO
                                //update state
                                _airshipBloc.notificationsEnabledSetSink.add(true);
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
                    child: StreamBuilder(
                      stream: _airshipBloc.channelStream,
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
        )
    );
  }

  @override
  void dispose() {
    _airshipBloc.dispose();
    super.dispose();
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}