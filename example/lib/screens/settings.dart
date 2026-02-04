import 'package:flutter/material.dart';
import 'package:airship_example/screens/tag_add.dart';
import 'package:airship_example/screens/named_user_add.dart';
import 'package:airship_example/styles.dart';
// ignore: depend_on_referenced_packages
import 'package:airship_flutter/airship_flutter.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  bool _isUpdatingPush = false;

  @override
  void initState() {
    super.initState();
    Airship.analytics.trackScreen('Settings');
  }

  Future<void> _handlePushToggle(bool enabled) async {
    if (_isUpdatingPush) return;

    setState(() => _isUpdatingPush = true);

    try {
      await Airship.push.setUserNotificationsEnabled(enabled);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              enabled 
                  ? 'Push notifications enabled' 
                  : 'Push notifications disabled',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update push settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdatingPush = false);
      }
    }
  }

  Future<void> _navigateToNamedUser() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NamedUserAdd(updateParent: _updateState),
      ),
    );
  }

  Future<void> _navigateToTags() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TagAdd(updateParent: _updateState),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Styles.borders,
        elevation: 2,
      ),
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          // Push Notifications Toggle
          FutureBuilder<bool?>(
            future: Airship.push.isUserNotificationsEnabled,
            builder: (context, snapshot) {
              final isEnabled = snapshot.data ?? false;
              
              return SwitchListTile(
                title: Text(
                  'Push Notifications',
                  style: Styles.settingsPrimaryText,
                ),
                subtitle: Text(
                  isEnabled ? 'Enabled' : 'Disabled',
                  style: Styles.settingsSecondaryText,
                ),
                value: isEnabled,
                onChanged: _isUpdatingPush ? null : _handlePushToggle,
                secondary: Icon(
                  isEnabled ? Icons.notifications_active : Icons.notifications_off,
                  color: isEnabled ? Colors.green : Colors.grey,
                ),
              );
            },
          ),
          const Divider(height: 1),
          
          // Named User
          FutureBuilder<String?>(
            future: Airship.contact.namedUserId,
            builder: (context, snapshot) {
              final namedUser = snapshot.data;
              final hasNamedUser = namedUser != null && namedUser.isNotEmpty;
              
              return ListTile(
                leading: Icon(
                  Icons.person,
                  color: hasNamedUser ? Colors.blue : Colors.grey,
                ),
                trailing: const Icon(Icons.chevron_right),
                title: Text('Named User', style: Styles.settingsPrimaryText),
                subtitle: Text(
                  hasNamedUser ? namedUser : "Not set",
                  style: Styles.settingsSecondaryText,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: _navigateToNamedUser,
              );
            },
          ),
          const Divider(height: 1),
          
          // Tags
          FutureBuilder<List<String>>(
            future: Airship.channel.tags,
            builder: (context, snapshot) {
              final tags = snapshot.data ?? [];
              final hasTags = tags.isNotEmpty;
              final tagsDisplay = hasTags ? tags.join(', ') : "Not set";
              
              return ListTile(
                leading: Icon(
                  Icons.label,
                  color: hasTags ? Colors.orange : Colors.grey,
                ),
                trailing: const Icon(Icons.chevron_right),
                title: Text('Tags', style: Styles.settingsPrimaryText),
                subtitle: Text(
                  tagsDisplay,
                  style: Styles.settingsSecondaryText,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                onTap: _navigateToTags,
              );
            },
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }

  void _updateState() {
    if (mounted) {
      setState(() {});
    }
  }
}
