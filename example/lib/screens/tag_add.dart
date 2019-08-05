import 'package:flutter/material.dart';
import 'package:airship_example/styles.dart';
import 'package:airship/airship.dart';
import 'package:airship_example/widgets/text_add_bar.dart';

class TagAdd extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    final focusNode = FocusNode();

    Widget _buildTagList(List<String> tags) {
      tags = List<String>.from(tags);

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

              Airship.removeTags([tag]);
            },
            child: ListTile(
              title: Text('$tag'),
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
        body: FutureBuilder(
          future: Airship.tags,
          builder: (context, snapshot) {
            return SafeArea(
              bottom: false,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextAddBar(
                      controller: controller,
                      focusNode: focusNode,
                      label: "Add a tag",
                      onTap: (text){
                        Airship.addTags([text]);
                      },
                    ),
                  ),
                  Expanded(
                      child: _buildTagList(List<String>.from(snapshot.data))
                  ),
                ],
              ),
            );
          },
        ));
  }
}
