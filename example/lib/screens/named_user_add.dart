import 'package:flutter/material.dart';
import 'package:airship_example/styles.dart';
import 'package:airship_example/widgets/text_add_bar.dart';
// ignore: depend_on_referenced_packages
import 'package:airship_flutter/airship_flutter.dart';

class NamedUserAdd extends StatefulWidget {
  final VoidCallback updateParent;

  const NamedUserAdd({Key? key, required this.updateParent}) : super(key: key);

  @override
  NamedUserAddState createState() => NamedUserAddState();
}

class NamedUserAddState extends State<NamedUserAdd> {
  @override
  void initState() {
    super.initState();
    Airship.analytics.trackScreen('Add Named User');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Named User"),
        backgroundColor: Styles.background,
      ),
      body: FutureBuilder<String?>(
        future: Airship.contact.namedUserId,
        builder: (context, snapshot) {
          return SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextAddBar(
                label: snapshot.data ?? "Not set",
                onTap: (text) {
                  Airship.contact.identify(text);
                  widget.updateParent();
                  Navigator.pop(context);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
