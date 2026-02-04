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
  static const double _standardSpacing = 16.0;
  static const double _buttonWidth = 100.0;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    initAirshipListeners();
    Airship.analytics.trackScreen('Home');
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initAirshipListeners() async {
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
          attributes: {
            "name": _uuid.v4(),
          },
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Activity started successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start activity: $e'),
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

  Future<void> _stopAllActivities() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    
    try {
      if (Platform.isIOS) {
        final activities = await Airship.liveActivityManager.listAll();
        
        if (activities.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No active activities to stop')),
            );
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No active updates to stop')),
            );
          }
          return;
        }
        
        for (final update in updates) {
          final stopRequest = LiveUpdateEndRequest(name: update.name);
          await Airship.liveUpdateManager.end(stopRequest);
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All activities stopped')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to stop activities: $e'),
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

  Future<void> _updateAllActivities() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    
    try {
      if (Platform.isIOS) {
        final activities = await Airship.liveActivityManager.listAll();
        
        if (activities.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No active activities to update')),
            );
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No active updates to update')),
            );
          }
          return;
        }

        for (final update in updates) {
          final currentEmoji = update.content['emoji'] ?? '';

          final request = LiveUpdateUpdateRequest(
            name: update.name,
            content: {
              'emoji': currentEmoji == '🙌' ? '👍' : '🙌',
            },
          );

          await Airship.liveUpdateManager.update(request);
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activities updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update activities: $e'),
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

  Widget _buildActionRow(
      String label, String buttonText, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: _standardSpacing),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: _buttonWidth,
            child: ElevatedButton(
              onPressed: _isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Styles.airshipBlue.withOpacity(0.8),
                disabledBackgroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: _standardSpacing),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Embedded View
              const AirshipEmbeddedView(
                embeddedId: "test",
                parentHeight: _embeddedViewHeight,
              ),
              const SizedBox(height: 24),
              // Airship Logo
              Image.asset(
                'assets/airship.png',
                semanticLabel: 'Airship Logo',
              ),
              const SizedBox(height: 24),
              // Enable Notifications Button
              FutureBuilder<bool?>(
                future: Airship.push.isUserNotificationsEnabled,
                builder: (context, AsyncSnapshot<bool?> snapshot) {
                  final pushEnabled = snapshot.data ?? false;
                  
                  if (pushEnabled) {
                    return const SizedBox.shrink();
                  }
                  
                  return NotificationsEnabledButton(
                    onPressed: () async {
                      await Airship.push.enableUserNotifications(
                        options: const EnableUserPushNotificationsArgs(
                          fallback: PromptPermissionFallback.systemSettings,
                        ),
                      );
                      if (mounted) {
                        setState(() {});
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              // Channel Identifier
              FutureBuilder<String?>(
                future: Airship.channel.identifier,
                builder: (context, snapshot) {
                  return Text(
                    snapshot.hasData && snapshot.data != null
                        ? snapshot.data!
                        : "Channel not set",
                    textAlign: TextAlign.center,
                    style: Styles.homePrimaryText,
                  );
                },
              ),
              const SizedBox(height: 36),
              // Live Activities/Updates Card
              Card(
                color: Colors.grey.withOpacity(0.1),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(_standardSpacing),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Platform.isIOS ? Icons.widgets : Icons.update,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            Platform.isIOS ? 'Live Activities' : 'Live Updates',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildActionRow('Start New', 'Start', _startNewActivity),
                      const SizedBox(height: 8),
                      _buildActionRow('End All', 'End', _stopAllActivities),
                      const SizedBox(height: 8),
                      _buildActionRow('Update All', 'Update', _updateAllActivities),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
