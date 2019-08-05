import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:airship_example/data/app_state.dart';
import 'package:airship_example/screens/tag_add.dart';
import 'package:airship_example/screens/named_user_add.dart';
import 'package:airship_example/styles.dart';
import 'package:airship/airship.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = ScopedModel.of<AppState>(context, rebuildOnChange: true);

    return ScopedModel(
      model: model,
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
            backgroundColor: Styles.borders,
          ),
          backgroundColor: Colors.white,
          body: ListView(
              children: ListTile.divideTiles(
                context: context,
                tiles: [
                  FutureBuilder(
                      future: Airship.userNotificationsEnabled,
                      builder: (context, snapshot) { return SwitchListTile(
                        //leading:Icon(Icons.settings_input_antenna),
                        title: Text('Push Enabled',
                          style: Styles.settingsPrimaryText,),
                        value: snapshot.hasData ? snapshot.data : false,
                        onChanged: (bool value){
                          model.setUserNotificationsEnabled(value);
                        },
                      );
                      }),
                  FutureBuilder(
                      future: Airship.namedUser,
                      builder: (context, snapshot) {
                        return ListTile(
                          trailing:Icon(Icons.edit),
                          title: Text('Named User',
                              style: Styles.settingsPrimaryText),
                          subtitle: Text(snapshot.hasData ? snapshot.data : "None set",
                              style: Styles.settingsSecondaryText),
                          onTap: (){
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => NamedUserAdd()));
                          },
                        );
                      }),
                  FutureBuilder(
                      future: Airship.tags,
                      builder: (context, snapshot) {
                        return ListTile(
                          trailing:Icon(Icons.edit),
                          title: Text('Tags',
                              style: Styles.settingsPrimaryText),
                          subtitle: Text(snapshot.hasData && snapshot.data.join(', ') != "" ? snapshot.data.join(', ') : "None set",
                              style: Styles.settingsSecondaryText),
                          onTap: (){
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => TagAdd()));
                          },
                        );
                      }),
                ],
              ).toList())

      ),
    );
  }
}