import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:airship_flutter/airship_flutter.dart';
import 'package:flutter_section_list/flutter_section_list.dart';
import 'dart:async';

class PreferenceCenter extends StatefulWidget {
  const PreferenceCenter({super.key});

  @override
  PreferenceCenterState createState() => PreferenceCenterState();
}

class PreferenceCenterState extends State<PreferenceCenter>
    with SectionAdapterMixin {
  String preferenceCenterId = "app_default";
  PreferenceCenterConfig? fullPreferenceCenterConfig;
  bool _configLoadCompleted = false;
  String? _configLoadError;
  var activeChannelSubscriptions = List<String>.empty(growable: true);
  Map<String, List<ChannelScope>> activeContactSubscriptions =
      <String, List<ChannelScope>>{};
  var isOptedInToNotifications = false;

  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    Airship.analytics.trackScreen('Preference Center');
    _initializeData();
  }

  @override
  void dispose() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  Future<void> _initializeData() async {
    await Future.wait([
      updateNotificationOptIn(),
      updatePreferenceCenterConfig(),
      fillInSubscriptionList(),
    ]);
    _initAirshipListeners();
  }

  void _initAirshipListeners() {
    _subscriptions.add(
      Airship.preferenceCenter.onDisplay.listen((event) {
        // Handle preference center display event if needed
      }),
    );

    _subscriptions.add(
      Airship.push.onNotificationStatusChanged.listen((event) {
        if (mounted) {
          setState(() {
            isOptedInToNotifications = event.status.isOptedIn;
          });
        }
      }),
    );
  }

  Future<void> updatePreferenceCenterConfig() async {
    if (mounted) setState(() {
      _configLoadCompleted = false;
      _configLoadError = null;
    });
    try {
      fullPreferenceCenterConfig =
          await Airship.preferenceCenter.getConfig(preferenceCenterId);
      _configLoadError = null;
    } catch (e) {
      debugPrint('Error loading preference center config: $e');
      fullPreferenceCenterConfig = null;
      _configLoadError = e.toString();
    }
    _configLoadCompleted = true;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> updateNotificationOptIn() async {
    try {
      final status = await Airship.push.notificationStatus;
      if (status != null && mounted) {
        setState(() {
          isOptedInToNotifications = status.isOptedIn;
        });
      }
    } catch (e) {
      debugPrint('Error updating notification opt-in status: $e');
    }
  }

  Future<void> fillInSubscriptionList() async {
    try {
      final contactSubscriptionLists = await Airship.contact.subscriptionLists;
      final channelSubscriptionLists = await Airship.channel.subscriptionLists;
      
      if (mounted) {
        setState(() {
          activeChannelSubscriptions = List.from(channelSubscriptionLists);
          activeContactSubscriptions = Map.from(contactSubscriptionLists);
        });
      }
    } catch (e) {
      debugPrint('Error loading subscription lists: $e');
    }
  }

  /// Filtered version of the preference center config based on the conditions
  PreferenceCenterConfig? get preferenceCenterConfig {
    var state = PreferenceCenterConditionState(isOptedInToNotifications);

    if (fullPreferenceCenterConfig == null) return null;

    var sections = fullPreferenceCenterConfig!.sections
        .where((s) => s.evaluateConditions(state))
        .map((s) => s.copy(
            s.items?.where((i) => i.evaluateConditions(state)).toList() ?? []))
        .toList();

    return fullPreferenceCenterConfig!.copy(sections);
  }

  bool isSubscribedChannelSubscription(String subscriptionId) {
    return activeChannelSubscriptions.contains(subscriptionId);
  }

  bool isSubscribedContactSubscription(
      String subscriptionId, List<ChannelScope> scopes) {
    if (scopes.isEmpty) {
      return activeContactSubscriptions.containsKey(subscriptionId);
    }

    if (activeContactSubscriptions[subscriptionId] != null) {
      List<ChannelScope> activeContactSubscriptionsScopes =
          activeContactSubscriptions[subscriptionId]!;
      if (scopes
          .every((item) => activeContactSubscriptionsScopes.contains(item))) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  void onPreferenceChannelItemToggled(String subscriptionId, bool subscribe) {
    final editor = Airship.channel.editSubscriptionLists();
    
    setState(() {
      if (subscribe) {
        editor.subscribe(subscriptionId);
        activeChannelSubscriptions.add(subscriptionId);
      } else {
        editor.unsubscribe(subscriptionId);
        activeChannelSubscriptions.remove(subscriptionId);
      }
    });
    
    editor.apply();
  }

  void applyContactSubscription(
      String subscriptionId, List<ChannelScope> scopes, bool subscribe) {
    final currentScopes = activeContactSubscriptions[subscriptionId] ?? [];
    
    if (subscribe) {
      final newScopes = List<ChannelScope>.from(currentScopes)..addAll(scopes);
      activeContactSubscriptions[subscriptionId] = newScopes;
    } else {
      final newScopes = List<ChannelScope>.from(currentScopes)
        ..removeWhere((item) => scopes.contains(item));
      activeContactSubscriptions[subscriptionId] = newScopes;
    }
  }

  void onPreferenceContactSubscriptionItemToggled(
      String subscriptionId, List<ChannelScope> scopes, bool subscribe) {
    final editor = Airship.contact.editSubscriptionLists();
    
    for (final scope in scopes) {
      if (subscribe) {
        editor.subscribe(subscriptionId, scope);
      } else {
        editor.unsubscribe(subscriptionId, scope);
      }
    }
    
    editor.apply();
    applyContactSubscription(subscriptionId, scopes, subscribe);
    
    if (mounted) {
      setState(() {});
    }
  }

  Widget bindChannelSubscriptionItem(
      PreferenceCenterChannelSubscriptionItem item, ColorScheme colorScheme) {
    final isSubscribed = isSubscribedChannelSubscription(item.subscriptionId);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: SwitchListTile(
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSubscribed 
                ? colorScheme.primaryContainer 
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isSubscribed ? Icons.notifications_active : Icons.notifications_outlined,
            color: isSubscribed ? colorScheme.primary : colorScheme.onSurfaceVariant,
            size: 22,
          ),
        ),
        title: Text(
          item.display.title ?? '',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: item.display.subtitle != null
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(item.display.subtitle!),
              )
            : null,
        value: isSubscribed,
        onChanged: (bool value) {
          onPreferenceChannelItemToggled(item.subscriptionId, value);
        },
      ),
    );
  }

  Widget bindContactSubscriptionItem(
      PreferenceCenterContactSubscriptionItem item, ColorScheme colorScheme) {
    final isSubscribed = isSubscribedContactSubscription(item.subscriptionId, []);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: SwitchListTile(
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSubscribed 
                ? colorScheme.primaryContainer 
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isSubscribed ? Icons.mail : Icons.mail_outline,
            color: isSubscribed ? colorScheme.primary : colorScheme.onSurfaceVariant,
            size: 22,
          ),
        ),
        title: Text(
          item.display.title ?? '',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: item.display.subtitle != null
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(item.display.subtitle!),
              )
            : null,
        value: isSubscribed,
        onChanged: (bool value) {
          onPreferenceContactSubscriptionItemToggled(
              item.subscriptionId, [], value);
        },
      ),
    );
  }

  List<Widget> contactScopes(
      PreferenceCenterContactSubscriptionGroupItem item, ColorScheme colorScheme) {
    return item.components.map((component) {
      final componentLabel = component.display.title;
      final scopes = component.scopes;
      final isSelected = isSubscribedContactSubscription(item.subscriptionId, scopes);
      
      return FilterChip(
        avatar: isSelected 
            ? Icon(Icons.check, size: 18, color: colorScheme.primary)
            : null,
        label: Text(componentLabel ?? ''),
        selected: isSelected,
        onSelected: (bool value) {
          onPreferenceContactSubscriptionItemToggled(
              item.subscriptionId, scopes, value);
        },
        showCheckmark: false,
        selectedColor: colorScheme.primaryContainer,
        backgroundColor: colorScheme.surfaceContainerHighest,
      );
    }).toList();
  }

  Widget bindContactSubscriptionGroupItem(
      PreferenceCenterContactSubscriptionGroupItem item, ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.category_outlined,
                    color: colorScheme.secondary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.display.title ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      if (item.display.subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            item.display.subtitle!,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: contactScopes(item, colorScheme),
            ),
          ],
        ),
      ),
    );
  }

  Widget bindAlertItem(PreferenceCenterAlertItem item, ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: colorScheme.primaryContainer.withOpacity(0.3),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.info_outline,
            color: colorScheme.primary,
            size: 22,
          ),
        ),
        title: Text(
          item.display.title ?? '',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),
        subtitle: item.display.subtitle != null
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(item.display.subtitle!),
              )
            : null,
      ),
    );
  }

  Widget bindContactManagementItem(
      PreferenceCenterContactManagementItem item, ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: colorScheme.secondaryContainer.withOpacity(0.3),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.person_outline,
            color: colorScheme.onSecondaryContainer,
            size: 22,
          ),
        ),
        title: Text(
          item.display.title ?? 'Contact management',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: item.display.subtitle != null
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(item.display.subtitle!),
              )
            : null,
      ),
    );
  }

  Widget item(IndexPath indexPath, ColorScheme colorScheme) {
    List<PreferenceCenterItem> items =
        preferenceCenterConfig?.sections[indexPath.section].items ?? [];
    PreferenceCenterItem item = items[indexPath.item];
    
    switch (item.type) {
      case PreferenceCenterItemType.channelSubscription:
        return bindChannelSubscriptionItem(
            item as PreferenceCenterChannelSubscriptionItem, colorScheme);
      case PreferenceCenterItemType.contactSubscription:
        return bindContactSubscriptionItem(
            item as PreferenceCenterContactSubscriptionItem, colorScheme);
      case PreferenceCenterItemType.contactSubscriptionGroup:
        return bindContactSubscriptionGroupItem(
            item as PreferenceCenterContactSubscriptionGroupItem, colorScheme);
      case PreferenceCenterItemType.alert:
        return bindAlertItem(item as PreferenceCenterAlertItem, colorScheme);
      case PreferenceCenterItemType.contactManagement:
        return bindContactManagementItem(
            item as PreferenceCenterContactManagementItem, colorScheme);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: !_configLoadCompleted
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Loading preferences...',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : fullPreferenceCenterConfig == null
              ? _configLoadError != null
                  ? _ErrorState(
                      colorScheme: colorScheme,
                      message: _configLoadError!,
                      onRetry: _initializeData,
                    )
                  : _EmptyState(
                      colorScheme: colorScheme,
                      reason: _EmptyReason.noConfig,
                    )
              : preferenceCenterConfig?.sections.isEmpty == true
                  ? _EmptyState(
                      colorScheme: colorScheme,
                      reason: _EmptyReason.allSectionsFiltered,
                      isOptedInToNotifications: isOptedInToNotifications,
                    )
                  : SectionListView.builder(adapter: this),
    );
  }

  @override
  int numberOfSections() {
    return preferenceCenterConfig?.sections.length ?? 0;
  }

  @override
  int numberOfItems(int section) {
    return preferenceCenterConfig?.sections[section].items?.length ?? 0;
  }

  @override
  Widget getItem(BuildContext context, IndexPath indexPath) {
    final colorScheme = Theme.of(context).colorScheme;
    return item(indexPath, colorScheme);
  }

  @override
  bool shouldExistHeader() {
    return preferenceCenterConfig != null && 
           preferenceCenterConfig!.display != null;
  }

  @override
  Widget getHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final display = preferenceCenterConfig?.display;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.tune,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  display?.title ?? 'Preferences',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          if (display?.subtitle != null && display!.subtitle!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                display.subtitle!,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  bool shouldExistSectionHeader(int section) {
    return preferenceCenterConfig?.sections[section].display != null;
  }

  @override
  Widget getSectionHeader(BuildContext context, int section) {
    final colorScheme = Theme.of(context).colorScheme;
    final sectionData = preferenceCenterConfig?.sections[section];
    final display = sectionData?.display;
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 24, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (display?.title ?? '').toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: colorScheme.primary,
              letterSpacing: 1.2,
            ),
          ),
          if (display?.subtitle != null && display!.subtitle!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                display.subtitle!,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

enum _EmptyReason {
  /// No preference center config was returned (e.g. not configured in Airship).
  noConfig,
  /// Config loaded but all sections are hidden by conditions (e.g. notification opt-in).
  allSectionsFiltered,
}

class _EmptyState extends StatelessWidget {
  final ColorScheme colorScheme;
  final _EmptyReason reason;
  final bool? isOptedInToNotifications;

  const _EmptyState({
    required this.colorScheme,
    required this.reason,
    this.isOptedInToNotifications,
  });

  @override
  Widget build(BuildContext context) {
    final String title;
    final String subtitle;
    switch (reason) {
      case _EmptyReason.noConfig:
        title = 'No preference center configured';
        subtitle =
            "Add a preference center with ID \"app_default\" in the Airship dashboard, or change preferenceCenterId in this screen.";
        break;
      case _EmptyReason.allSectionsFiltered:
        title = 'No preferences to show';
        subtitle = isOptedInToNotifications == false
            ? 'Some preferences may appear when notifications are enabled.'
            : 'All sections are currently hidden by their conditions.';
        break;
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
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
                Icons.tune_outlined,
                size: 48,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final ColorScheme colorScheme;
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.colorScheme,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Failed to load preferences',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
