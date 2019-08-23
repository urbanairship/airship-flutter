import 'package:flutter/material.dart';
import 'package:airship_example/styles.dart';
import 'package:airship_example/bloc/airship_bloc.dart';
import 'package:airship_example/widgets/notifications_enabled_button.dart';

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
                        enableNotificationsButton = Center (child: NotificationsEnabledButton(bloc:_airshipBloc)
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