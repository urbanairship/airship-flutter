import 'package:flutter/material.dart';
import 'package:airship_example/styles.dart';
import 'package:airship_example/widgets/text_add_bar.dart';
// ignore: depend_on_referenced_packages
import 'package:airship_flutter/airship_flutter.dart';

class TagAdd extends StatefulWidget {
  final VoidCallback updateParent;

  const TagAdd({super.key, required this.updateParent});

  @override
  TagAddState createState() => TagAddState();
}

class TagAddState extends State<TagAdd> {
  bool _isLoading = false;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    Airship.analytics.trackScreen('Add Tag');
    _loadTags();
  }

  Future<void> _loadTags() async {
    try {
      final tags = await Airship.channel.tags;
      if (mounted) {
        setState(() {
          _tags = tags;
        });
      }
    } catch (e) {
      debugPrint('Error loading tags: $e');
    }
  }

  Future<void> _handleAddTag(String tagText) async {
    if (tagText.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid tag'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final trimmedTag = tagText.trim();
    
    if (_tags.contains(trimmedTag)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tag already exists'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      await Airship.channel.addTags([trimmedTag]);
      
      if (mounted) {
        setState(() {
          _tags.add(trimmedTag);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tag "$trimmedTag" added'),
            backgroundColor: Colors.green,
          ),
        );
        
        widget.updateParent();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add tag: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleRemoveTag(String tag) async {
    setState(() => _isLoading = true);

    try {
      await Airship.channel.removeTags([tag]);
      
      if (mounted) {
        setState(() {
          _tags.remove(tag);
        });
        
        widget.updateParent();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove tag: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Tags"),
        backgroundColor: Styles.background,
        elevation: 0,
        actions: [
          if (_tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Center(
                child: Chip(
                  label: Text(
                    '${_tags.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Styles.airshipBlue,
                ),
              ),
            ),
        ],
      ),
      backgroundColor: Styles.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextAddBar(
                label: "Add a tag",
                onTap: _isLoading ? null : _handleAddTag,
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: LinearProgressIndicator(),
              ),
            if (_tags.isEmpty && !_isLoading)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.label_off,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No tags yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add your first tag above',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (_tags.isNotEmpty)
              Expanded(child: _buildTagList(_tags)),
          ],
        ),
      ),
    );
  }

  Widget _buildTagList(List<String> tags) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      itemCount: tags.length,
      itemBuilder: (context, index) {
        final tag = tags[index];
        return Dismissible(
          key: ValueKey(tag),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20.0),
            decoration: BoxDecoration(
              color: Styles.airshipRed,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
              size: 32,
            ),
          ),
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Confirm'),
                  content: Text('Remove tag "$tag"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Remove'),
                    ),
                  ],
                );
              },
            );
          },
          onDismissed: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Tag "$tag" removed'),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () async {
                    await Airship.channel.addTags([tag]);
                    _loadTags();
                    widget.updateParent();
                  },
                ),
              ),
            );
            _handleRemoveTag(tag);
          },
          child: Card(
            elevation: 2.0,
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Styles.airshipBlue.withOpacity(0.2),
                child: const Icon(
                  Icons.label,
                  color: Styles.airshipBlue,
                ),
              ),
              title: Text(
                tag,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: _isLoading
                    ? null
                    : () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Confirm'),
                              content: Text('Remove tag "$tag"?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: const Text('Remove'),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirm == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Tag "$tag" removed')),
                          );
                          _handleRemoveTag(tag);
                        }
                      },
              ),
            ),
          ),
        );
      },
    );
  }
}
