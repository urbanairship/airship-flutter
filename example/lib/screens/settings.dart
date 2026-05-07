import 'package:flutter/material.dart';
import 'package:airship_example/screens/tag_add.dart';
import 'package:airship_example/screens/named_user_add.dart';
import 'package:airship_example/styles.dart';
// ignore: depend_on_referenced_packages
import 'package:airship_flutter/airship_flutter.dart';

class Settings extends StatefulWidget {
  final ThemeModeNotifier themeModeNotifier;

  const Settings({
    super.key,
    required this.themeModeNotifier,
  });

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
        _showSnackBar(
          enabled 
              ? 'Push notifications enabled' 
              : 'Push notifications disabled',
          isSuccess: true,
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to update push settings: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdatingPush = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false, bool isError = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    Color? backgroundColor;
    
    if (isSuccess) {
      backgroundColor = Colors.green.shade600;
    } else if (isError) {
      backgroundColor = colorScheme.error;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
      ),
    );
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

  void _updateState() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Appearance Section
          _SectionHeader(title: 'Appearance', colorScheme: colorScheme),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,
                      color: colorScheme.primary,
                      size: 22,
                    ),
                  ),
                  title: const Text('Theme'),
                  subtitle: Text(_getThemeModeText()),
                  trailing: SegmentedButton<ThemeMode>(
                    style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode, size: 18),
                      ),
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.brightness_auto, size: 18),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode, size: 18),
                      ),
                    ],
                    selected: {widget.themeModeNotifier.themeMode},
                    onSelectionChanged: (Set<ThemeMode> selection) {
                      widget.themeModeNotifier.setThemeMode(selection.first);
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Notifications Section
          _SectionHeader(title: 'Notifications', colorScheme: colorScheme),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: FutureBuilder<bool?>(
              future: Airship.push.isUserNotificationsEnabled,
              builder: (context, snapshot) {
                final isEnabled = snapshot.data ?? false;
                
                return SwitchListTile(
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isEnabled 
                          ? Colors.green.withValues(alpha: 0.15)
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isEnabled ? Icons.notifications_active : Icons.notifications_off,
                      color: isEnabled ? Colors.green.shade600 : colorScheme.onSurfaceVariant,
                      size: 22,
                    ),
                  ),
                  title: const Text('Push Notifications'),
                  subtitle: Text(isEnabled ? 'Enabled' : 'Disabled'),
                  value: isEnabled,
                  onChanged: _isUpdatingPush ? null : _handlePushToggle,
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // User Identity Section
          _SectionHeader(title: 'User Identity', colorScheme: colorScheme),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                FutureBuilder<String?>(
                  future: Airship.contact.namedUserId,
                  builder: (context, snapshot) {
                    final namedUser = snapshot.data;
                    final hasNamedUser = namedUser != null && namedUser.isNotEmpty;
                    
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: hasNamedUser 
                              ? colorScheme.primaryContainer
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.person,
                          color: hasNamedUser 
                              ? colorScheme.primary 
                              : colorScheme.onSurfaceVariant,
                          size: 22,
                        ),
                      ),
                      title: const Text('Named User'),
                      subtitle: Text(
                        hasNamedUser ? namedUser : 'Not set',
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onTap: _navigateToNamedUser,
                    );
                  },
                ),
                Divider(height: 1, indent: 72, endIndent: 16),
                FutureBuilder<List<String>>(
                  future: Airship.channel.tags,
                  builder: (context, snapshot) {
                    final tags = snapshot.data ?? [];
                    final hasTags = tags.isNotEmpty;
                    final tagsDisplay = hasTags 
                        ? '${tags.length} tag${tags.length > 1 ? 's' : ''}' 
                        : 'Not set';
                    
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: hasTags 
                              ? Colors.orange.withValues(alpha: 0.15)
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.label,
                          color: hasTags 
                              ? Colors.orange.shade700 
                              : colorScheme.onSurfaceVariant,
                          size: 22,
                        ),
                      ),
                      title: const Text('Tags'),
                      subtitle: Text(
                        tagsDisplay,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (hasTags)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${tags.length}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.chevron_right,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                      onTap: _navigateToTags,
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Channel Info Section
          _SectionHeader(title: 'Channel Info', colorScheme: colorScheme),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                FutureBuilder<String?>(
                  future: Airship.channel.identifier,
                  builder: (context, snapshot) {
                    final channelId = snapshot.data;
                    final hasChannel = channelId != null && channelId.isNotEmpty;
                    
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.fingerprint,
                          color: colorScheme.primary,
                          size: 22,
                        ),
                      ),
                      title: const Text('Channel ID'),
                      subtitle: Text(
                        hasChannel ? channelId : 'Not available',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.copy,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                        onPressed: hasChannel ? () {
                          _showSnackBar('Channel ID copied');
                        } : null,
                        tooltip: 'Copy',
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // App Info
          Center(
            child: Column(
              children: [
                Text(
                  'Airship Flutter SDK',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sample App',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _getThemeModeText() {
    switch (widget.themeModeNotifier.themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final ColorScheme colorScheme;

  const _SectionHeader({
    required this.title,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 8, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
