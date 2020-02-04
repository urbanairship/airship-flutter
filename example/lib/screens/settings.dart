import 'package:flutter/material.dart';
import 'package:airship_example/screens/tag_add.dart';
import 'package:airship_example/screens/named_user_add.dart';
import 'package:airship_example/styles.dart';
import 'package:airship_flutter/airship.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  void initState() {
    Airship.trackScreen('Settings');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          backgroundColor: Styles.borders,
        ),
        backgroundColor: Colors.white,
        body: ListView(
            children: ListTile.divideTiles(
              context: context,
              tiles: [ FutureBuilder(
                  future: Airship.userNotificationsEnabled,
                  builder: (context, snapshot) {
                    return SwitchListTile(
                      title: Text('Push Enabled',
                        style: Styles.settingsPrimaryText,),
                      value: snapshot.data ?? false,
                      onChanged: (bool enabled){
                        Airship.setUserNotificationsEnabled(enabled);
                      },
                    );}),
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
                              MaterialPageRoute(builder: (context) => NamedUserAdd(updateParent:updateState)));
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
                              MaterialPageRoute(builder: (context) => TagAdd(updateParent:updateState)));
                        },
                      );
                    }),
              ],
            ).toList())
    );
  }

  updateState() {
    setState(() {});
  }
}