import 'package:flutter/material.dart';
import 'package:airship_example/styles.dart';
import 'package:airship/airship.dart';
import 'package:airship_example/widgets/text_add_bar.dart';
import 'package:airship_example/bloc/bloc.dart';

class TagAdd extends StatelessWidget {
  final AirshipBloc _airshipBloc = AirshipBloc();

  @override
  Widget build(BuildContext context) {
    Widget _buildTagList(List<String> tags) {
      return ListView.builder(
        itemCount: tags != null ? tags.length : 0,
        itemBuilder: (context, index) {
          var tag = tags[index];

          return Dismissible(
            key: Key(UniqueKey().toString()),
            background: Container(color: Styles.airshipRed),
            onDismissed: (direction) {
              Scaffold
                  .of(context)
                  .showSnackBar(SnackBar(content: Text("tag \"$tag\" removed")));
              tags.remove(tag);
              _airshipBloc.tagsRemovedSink.add([tag]);
            },
            child: Card(
                elevation: 5.0,
                child: ListTile(
                  title: Text('$tag'),
                )
            ),
          );
        },
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: Text("Add Tag"),
          backgroundColor: Styles.background,
        ),
        body: StreamBuilder<List<String>>(
          stream: _airshipBloc.tagsStream,
          builder: (context, snapshot) {

            Expanded expandedList;

            if (snapshot.hasData) {
              expandedList = Expanded(
                  child: _buildTagList(snapshot.hasData ? List<String>.from(snapshot.data) : null)
              );
            }

            return SafeArea(
              bottom: false,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextAddBar(
                      label: "Add a tag",
                      onTap: (tagText){
                        FocusScope.of(context).unfocus();

                        _airshipBloc.tagsAddedSink.add([tagText]);
                      },
                    ),
                  ),
                  expandedList,
                ],
              ),
            );
          },
        ));
  }
}
