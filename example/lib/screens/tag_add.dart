import 'package:flutter/material.dart';
import 'package:airship_example/styles.dart';
import 'package:airship_example/widgets/text_add_bar.dart';
import 'package:airship_flutter/airship_flutter.dart';

class TagAdd extends StatefulWidget {
  final updateParent;

  TagAdd({this.updateParent});

  @override
  TagAddState createState() => TagAddState(updateParent: updateParent);
}

class TagAddState extends State<TagAdd> {
  final updateParent;

  TagAddState({this.updateParent});

  @override
  void initState() {
    Airship.trackScreen('Add Tag');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildTagList(List<String> tags) {
      return ListView.builder(
        itemCount: tags.length,
        itemBuilder: (context, index) {
          var tag = tags[index];

          return Dismissible(
            key: Key(UniqueKey().toString()),
            background: Container(color: Styles.airshipRed),
            onDismissed: (direction) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("tag \"$tag\" removed")));
              tags.remove(tag);
              Airship.removeTags([tag]);
              updateState();
            },
            child: Card(
                elevation: 5.0,
                child: ListTile(
                  title: Text('$tag'),
                )),
          );
        },
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: Text("Add Tag"),
          backgroundColor: Styles.background,
        ),
        body: FutureBuilder<List<String>>(
          future: Airship.tags,
          builder: (context, snapshot) {
            Expanded? expandedList;

            if (snapshot.hasData) {
              expandedList = Expanded(child: _buildTagList(snapshot.data!));
            }

            return SafeArea(
              bottom: false,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextAddBar(
                      label: "Add a tag",
                      onTap: (tagText) {
                        FocusScope.of(context).unfocus();
                        Airship.addTags([tagText]);
                        updateState();
                      },
                    ),
                  ),
                  expandedList ?? Container(),
                ],
              ),
            );
          },
        ));
  }

  updateState() {
    updateParent();
    setState(() {});
  }
}
