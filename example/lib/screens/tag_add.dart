import 'package:flutter/material.dart';
import 'package:airship_example/styles.dart';
import 'package:airship_example/widgets/text_add_bar.dart';
// ignore: depend_on_referenced_packages
import 'package:airship_flutter/airship_flutter.dart';

class TagAdd extends StatefulWidget {
  final VoidCallback updateParent;

  const TagAdd({Key? key, required this.updateParent}) : super(key: key);

  @override
  TagAddState createState() => TagAddState();
}

class TagAddState extends State<TagAdd> {
  @override
  void initState() {
    super.initState();
    Airship.analytics.trackScreen('Add Tag');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Tag"),
        backgroundColor: Styles.background,
      ),
      body: FutureBuilder<List<String>>(
        future: Airship.channel.tags,
        builder: (context, snapshot) {
          return SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextAddBar(
                    label: "Add a tag",
                    onTap: (tagText) {
                      FocusScope.of(context).unfocus();
                      Airship.channel.addTags([tagText]);
                      _updateState();
                    },
                  ),
                ),
                if (snapshot.hasData)
                  Expanded(child: _buildTagList(snapshot.data!))
                else
                  const SizedBox.shrink(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTagList(List<String> tags) {
    return ListView.builder(
      itemCount: tags.length,
      itemBuilder: (context, index) {
        final tag = tags[index];
        return Dismissible(
          key: ValueKey(tag),
          background: Container(color: Styles.airshipRed),
          onDismissed: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('tag "$tag" removed')),
            );
            Airship.channel.removeTags([tag]);
            _updateState();
          },
          child: Card(
            elevation: 5.0,
            child: ListTile(title: Text(tag)),
          ),
        );
      },
    );
  }

  void _updateState() {
    widget.updateParent();
    setState(() {});
  }
}
