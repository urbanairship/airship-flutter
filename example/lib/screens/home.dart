import 'package:flutter/material.dart';
import 'package:airship_example/styles.dart';
import 'package:airship_example/widgets/notifications_enabled_button.dart';
// ignore: depend_on_referenced_packages
import 'package:airship_flutter/airship_flutter.dart';
import 'dart:io' show Platform;
import 'package:uuid/uuid.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  static const Uuid _uuid = Uuid();
  static const double _embeddedViewHeight = 200.0;
  static const String _embeddedViewId = 'test';

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initAirshipListeners();
    Airship.analytics.trackScreen('Home');
  }

  Future<void> _initAirshipListeners() async {
    Airship.channel.onChannelCreated.listen((event) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _startNewActivity() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    
    try {
      if (Platform.isIOS) {
        final startRequest = LiveActivityStartRequest(
          attributesType: 'ExampleWidgetsAttributes',
          attributes: {'name': _uuid.v4()},
          content: LiveActivityContent(
            state: {'emoji': '🙌'}, 
            relevanceScore: 0.0,
          ),
        );
        await Airship.liveActivityManager.start(startRequest);
      } else if (Platform.isAndroid) {
        final createRequest = LiveUpdateStartRequest(
          name: "Cool",
          type: 'Example',
          content: {'emoji': '🙌'},
        );
        await Airship.liveUpdateManager.start(createRequest);
      }
      
      if (mounted) {
        _showSnackBar('Activity started successfully', isSuccess: true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to start activity: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _stopAllActivities() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    
    try {
      if (Platform.isIOS) {
        final activities = await Airship.liveActivityManager.listAll();
        
        if (activities.isEmpty) {
          if (mounted) {
            _showSnackBar('No active activities to stop');
          }
          return;
        }
        
        for (final activity in activities) {
          final stopRequest = LiveActivityStopRequest(
            attributesType: 'ExampleWidgetsAttributes',
            activityId: activity.id,
            dismissalPolicy: LiveActivityDismissalPolicyImmediate(),
          );
          await Airship.liveActivityManager.end(stopRequest);
        }
      } else if (Platform.isAndroid) {
        final updates = await Airship.liveUpdateManager.listAll();
        
        if (updates.isEmpty) {
          if (mounted) {
            _showSnackBar('No active updates to stop');
          }
          return;
        }
        
        for (final update in updates) {
          final stopRequest = LiveUpdateEndRequest(name: update.name);
          await Airship.liveUpdateManager.end(stopRequest);
        }
      }
      
      if (mounted) {
        _showSnackBar('All activities stopped', isSuccess: true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to stop activities: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateAllActivities() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    
    try {
      if (Platform.isIOS) {
        final activities = await Airship.liveActivityManager.listAll();
        
        if (activities.isEmpty) {
          if (mounted) {
            _showSnackBar('No active activities to update');
          }
          return;
        }
        
        for (final activity in activities) {
          final content = LiveActivityContent(
            state: {'emoji': '🙌'}, 
            relevanceScore: 0.0,
          );

          final updateRequest = LiveActivityUpdateRequest(
            attributesType: 'ExampleWidgetsAttributes',
            activityId: activity.id,
            content: content,
          );
          await Airship.liveActivityManager.update(updateRequest);
        }
      } else if (Platform.isAndroid) {
        final updates = await Airship.liveUpdateManager.listAll();
        
        if (updates.isEmpty) {
          if (mounted) {
            _showSnackBar('No active updates to update');
          }
          return;
        }

        for (final update in updates) {
          final currentEmoji = update.content['emoji'] ?? '';
          final request = LiveUpdateUpdateRequest(
            name: update.name,
            content: {'emoji': currentEmoji == '🙌' ? '👍' : '🙌'},
          );
          await Airship.liveUpdateManager.update(request);
        }
      }
      
      if (mounted) {
        _showSnackBar('Activities updated successfully', isSuccess: true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to update activities: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Airship'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildEmbeddedViewSection(colorScheme),
              const SizedBox(height: 24),
              _buildLogoSection(colorScheme, isDark),
              const SizedBox(height: 24),
              _buildNotificationsSection(),
              _buildChannelIdCard(colorScheme),
              const SizedBox(height: 16),
              _buildLiveActivitiesCard(colorScheme),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmbeddedViewSection(ColorScheme colorScheme) {
    return Column(
      children: [
        AirshipEmbeddedView(
          embeddedId: _embeddedViewId, parentHeight: _embeddedViewHeight,
        ),
      ],
    );
  }

  Widget _buildLogoSection(ColorScheme colorScheme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHighest.withOpacity(0.5)
            : colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Image.asset(
        'assets/airship.png',
        semanticLabel: 'Airship Logo',
        height: 60,
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return FutureBuilder<bool?>(
      future: Airship.push.isUserNotificationsEnabled,
      builder: (context, snapshot) {
        if (snapshot.data == true) return const SizedBox.shrink();
        return NotificationsEnabledButton(
          onPressed: () async {
            await Airship.push.enableUserNotifications(
              options: EnableUserPushNotificationsArgs(
                fallback: PromptPermissionFallback.systemSettings,
              ),
            );
            if (mounted) setState(() {});
          },
        );
      },
    );
  }

  Widget _buildChannelIdCard(ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.fingerprint, color: colorScheme.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Channel ID',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FutureBuilder<String?>(
                    future: Airship.channel.identifier,
                    builder: (context, snapshot) {
                      final channelId = snapshot.data;
                      final hasChannel = channelId != null && channelId.isNotEmpty;
                      return Text(
                        hasChannel ? channelId! : 'Not available',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: hasChannel
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.copy, color: colorScheme.primary, size: 20),
              onPressed: () async {
                final channelId = await Airship.channel.identifier;
                if (channelId != null && mounted) _showSnackBar('Channel ID copied');
              },
              tooltip: 'Copy Channel ID',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveActivitiesCard(ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Platform.isIOS ? Icons.widgets : Icons.update,
                    color: colorScheme.secondary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  Platform.isIOS ? 'Live Activities' : 'Live Updates',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: LinearProgressIndicator(),
              ),
            _ActionButton(
              icon: Icons.play_arrow_rounded,
              label: 'Start New',
              onPressed: _isLoading ? null : _startNewActivity,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 12),
            _ActionButton(
              icon: Icons.stop_rounded,
              label: 'End All',
              onPressed: _isLoading ? null : _stopAllActivities,
              colorScheme: colorScheme,
              isDestructive: true,
            ),
            const SizedBox(height: 12),
            _ActionButton(
              icon: Icons.refresh_rounded,
              label: 'Update All',
              onPressed: _isLoading ? null : _updateAllActivities,
              colorScheme: colorScheme,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final ColorScheme colorScheme;
  final bool isDestructive;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.colorScheme,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? colorScheme.error : colorScheme.primary;
    final backgroundColor = isDestructive 
        ? colorScheme.errorContainer.withOpacity(0.3)
        : colorScheme.primaryContainer.withOpacity(0.3);

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
