import 'package:flutter/material.dart';
import 'package:airship_example/styles.dart';
import 'package:airship_example/widgets/text_add_bar.dart';
import 'package:airship_flutter/airship.dart';

class NamedUserAdd extends StatelessWidget {
  final updateParent;

  NamedUserAdd({this.updateParent});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Add Named User"),
          backgroundColor: Styles.background,
        ),
        body: FutureBuilder(
          future: Airship.namedUser,
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
                        Airship.setNamedUser(text);
                        updateParent();
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