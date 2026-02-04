import 'package:flutter/material.dart';
import 'package:airship_example/styles.dart';
import 'package:airship_example/widgets/text_add_bar.dart';
// ignore: depend_on_referenced_packages
import 'package:airship_flutter/airship_flutter.dart';

class NamedUserAdd extends StatefulWidget {
  final VoidCallback updateParent;

  const NamedUserAdd({super.key, required this.updateParent});

  @override
  NamedUserAddState createState() => NamedUserAddState();
}

class NamedUserAddState extends State<NamedUserAdd> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Airship.analytics.trackScreen('Add Named User');
  }

  Future<void> _handleIdentify(String text) async {
    if (text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid named user ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Airship.contact.identify(text.trim());
      
      if (mounted) {
        widget.updateParent();
        Navigator.pop(context);
        
        // Show success message on previous screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Named user set to: ${text.trim()}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to set named user: $e'),
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
        title: const Text("Add Named User"),
        backgroundColor: Styles.background,
        elevation: 0,
      ),
      backgroundColor: Styles.background,
      body: FutureBuilder<String?>(
        future: Airship.contact.namedUserId,
        builder: (context, snapshot) {
          final currentNamedUser = snapshot.data;
          
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (currentNamedUser != null && currentNamedUser.isNotEmpty)
                    Card(
                      color: Colors.blue.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: Colors.blue),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Current: $currentNamedUser',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  TextAddBar(
                    label: currentNamedUser ?? "Not set",
                    onTap: _isLoading ? null : _handleIdentify,
                  ),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
