import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:airship_flutter/airship_flutter.dart';

class TagAdd extends StatefulWidget {
  final VoidCallback updateParent;

  const TagAdd({super.key, required this.updateParent});

  @override
  TagAddState createState() => TagAddState();
}

class TagAddState extends State<TagAdd> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = false;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    Airship.analytics.trackScreen('Add Tag');
    _loadTags();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
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

  Future<void> _handleAddTag() async {
    final tagText = _controller.text.trim();
    
    if (tagText.isEmpty) {
      _showSnackBar('Please enter a valid tag', isWarning: true);
      return;
    }

    if (_tags.contains(tagText)) {
      _showSnackBar('Tag already exists', isWarning: true);
      return;
    }

    _focusNode.unfocus();
    setState(() => _isLoading = true);

    try {
      await Airship.channel.addTags([tagText]);
      
      if (mounted) {
        setState(() {
          _tags.add(tagText);
        });
        _controller.clear();
        _showSnackBar('Tag "$tagText" added', isSuccess: true);
        widget.updateParent();
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to add tag: $e', isError: true);
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
        _showSnackBar('Tag removed', isSuccess: true);
        widget.updateParent();
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to remove tag: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false, bool isError = false, bool isWarning = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    Color? backgroundColor;
    
    if (isSuccess) {
      backgroundColor = Colors.green.shade600;
    } else if (isError) {
      backgroundColor = colorScheme.error;
    } else if (isWarning) {
      backgroundColor = Colors.orange.shade700;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<bool?> _confirmRemove(String tag) async {
    final colorScheme = Theme.of(context).colorScheme;
    
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Tag'),
          content: Text('Are you sure you want to remove "$tag"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
              ),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
        title: const Text('Manage Tags'),
        actions: [
          if (_tags.isNotEmpty)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_tags.length}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Add Tag Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: 'Enter a new tag',
                      prefixIcon: Icon(
                        Icons.label_outline,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _controller.clear();
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _handleAddTag(),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _isLoading || _controller.text.trim().isEmpty
                      ? null
                      : _handleAddTag,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Add'),
                ),
              ],
            ),
          ),
          
          // Loading indicator
          if (_isLoading)
            LinearProgressIndicator(color: colorScheme.primary),
          
          // Tags List
          Expanded(
            child: _tags.isEmpty
                ? _EmptyState(colorScheme: colorScheme)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _tags.length,
                    itemBuilder: (context, index) {
                      final tag = _tags[index];
                      return _TagCard(
                        tag: tag,
                        onDelete: () async {
                          final confirmed = await _confirmRemove(tag);
                          if (confirmed == true) {
                            _handleRemoveTag(tag);
                          }
                        },
                        colorScheme: colorScheme,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _TagCard extends StatelessWidget {
  final String tag;
  final VoidCallback onDelete;
  final ColorScheme colorScheme;

  const _TagCard({
    required this.tag,
    required this.onDelete,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.label,
            color: Colors.orange.shade700,
            size: 22,
          ),
        ),
        title: Text(
          tag,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.delete_outline,
            color: colorScheme.error,
          ),
          onPressed: onDelete,
          tooltip: 'Remove tag',
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ColorScheme colorScheme;

  const _EmptyState({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.label_off_outlined,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No tags yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first tag above',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
