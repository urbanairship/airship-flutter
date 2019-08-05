import 'package:flutter/material.dart';
import 'package:airship_example/styles.dart';
import 'package:airship/airship.dart';
import 'package:airship_example/widgets/text_add_bar.dart';

class NamedUserAdd extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _controller = TextEditingController();
    final _focusNode = FocusNode();

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
                      controller: _controller,
                      focusNode: _focusNode,
                      label: snapshot.hasData ? snapshot.data : "Not set",
                      onTap: (text){
                        Airship.setNamedUser(text);
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