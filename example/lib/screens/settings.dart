import 'package:flutter/material.dart';
import 'package:airship_example/screens/tag_add.dart';
import 'package:airship_example/screens/named_user_add.dart';
import 'package:airship_example/styles.dart';
import 'package:airship_example/bloc/bloc.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AirshipBloc _airshipBloc = AirshipBloc();

    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          backgroundColor: Styles.borders,
        ),
        backgroundColor: Colors.white,
        body: ListView(
            children: ListTile.divideTiles(
              context: context,
              tiles: [
                StreamBuilder(
                    stream: _airshipBloc.notificationsEnabledStream,
                    builder: (context, snapshot) { return SwitchListTile(
                      //leading:Icon(Icons.settings_input_antenna),
                      title: Text('Push Enabled',
                        style: Styles.settingsPrimaryText,),
                      value: snapshot.hasData ? snapshot.data : false,
                      onChanged: (bool value){
                        _airshipBloc.notificationsEnabledSetSink.add(value);
                        },
                    );
                    }),
                StreamBuilder(
                    stream: _airshipBloc.namedUserStream,
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
                StreamBuilder(
                    stream: _airshipBloc.tagsStream,
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
    );
  }
}