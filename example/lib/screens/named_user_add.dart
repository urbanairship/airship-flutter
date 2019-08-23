import 'package:flutter/material.dart';
import 'package:airship_example/styles.dart';
import 'package:airship_example/widgets/text_add_bar.dart';
import 'package:airship_example/bloc/bloc.dart';

class NamedUserAdd extends StatelessWidget {
  final AirshipBloc _airshipBloc = AirshipBloc();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Add Named User"),
          backgroundColor: Styles.background,
        ),
        body: StreamBuilder(
          stream: _airshipBloc.namedUserStream,
          builder: (context, snapshot) {
            return SafeArea(
              bottom: false,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextAddBar(
                      label: snapshot.hasData ? snapshot.data : "Not set",
                      onTap: (text){
                        _airshipBloc.namedUserSetSink.add(text);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ));
  }
}