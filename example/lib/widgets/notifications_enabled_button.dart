import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:airship_example/styles.dart';
import 'package:airship_example/bloc/bloc.dart';

typedef void TapCallback(String text);

class NotificationsEnabledButton extends StatelessWidget {
  final AirshipBloc bloc;

  NotificationsEnabledButton({
    @required this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    return Center (child: Padding(
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
                  //update state
                  bloc.notificationsEnabledSetSink.add(true);
                }
            )
        )
    );
  }
}