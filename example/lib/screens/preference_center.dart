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
  String preferenceCenterId = "neat";
  PreferenceCenterConfig? fullPreferenceCenterConfig;
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
    initAirshipListeners();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  void initAirshipListeners() {
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
    try {
      fullPreferenceCenterConfig =
          await Airship.preferenceCenter.getConfig(preferenceCenterId);
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error loading preference center config: $e');
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
  /// defined by sections and items.
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
      PreferenceCenterChannelSubscriptionItem item) {
    return SwitchListTile(
      title: Text(
        item.display.title ?? '',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: item.display.subtitle != null
          ? Text(item.display.subtitle!)
          : null,
      value: isSubscribedChannelSubscription(item.subscriptionId),
      onChanged: (bool value) {
        onPreferenceChannelItemToggled(item.subscriptionId, value);
      },
    );
  }

  Widget bindContactSubscriptionItem(
      PreferenceCenterContactSubscriptionItem item) {
    return SwitchListTile(
      title: Text(
        item.display.title ?? '',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: item.display.subtitle != null
          ? Text(item.display.subtitle!)
          : null,
      value: isSubscribedContactSubscription(item.subscriptionId, []),
      onChanged: (bool value) {
        onPreferenceContactSubscriptionItemToggled(
            item.subscriptionId, [], value);
      },
    );
  }

  List<Widget> contactScopes(
      PreferenceCenterContactSubscriptionGroupItem item) {
    return item.components.map((component) {
      final componentLabel = component.display.title;
      final scopes = component.scopes;
      
      return FilterChip(
        avatar: CircleAvatar(
          backgroundColor: Colors.grey.shade800,
        ),
        label: Text(componentLabel ?? ''),
        selected: isSubscribedContactSubscription(item.subscriptionId, scopes),
        onSelected: (bool value) {
          onPreferenceContactSubscriptionItemToggled(
              item.subscriptionId, scopes, value);
        },
      );
    }).toList();
  }

  Widget bindContactSubscriptionGroupItem(
      PreferenceCenterContactSubscriptionGroupItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            item.display.title ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: item.display.subtitle != null
              ? Text(item.display.subtitle!)
              : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Wrap(
            runAlignment: WrapAlignment.start,
            spacing: 10,
            runSpacing: 8,
            children: contactScopes(item),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget bindAlertItem(PreferenceCenterAlertItem item) {
    return ListTile(
      leading: const Icon(Icons.info_outline, color: Colors.blue),
      title: Text(
        item.display.title ?? '',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: item.display.subtitle != null
          ? Text(item.display.subtitle!)
          : null,
    );
  }

  Widget item(IndexPath indexPath) {
    List<PreferenceCenterItem> items =
        preferenceCenterConfig?.sections[indexPath.section].items ?? [];
    PreferenceCenterItem item = items[indexPath.item];
    switch (item.type) {
      case PreferenceCenterItemType.channelSubscription:
        return bindChannelSubscriptionItem(
            item as PreferenceCenterChannelSubscriptionItem);
      case PreferenceCenterItemType.contactSubscription:
        return bindContactSubscriptionItem(
            item as PreferenceCenterContactSubscriptionItem);
      case PreferenceCenterItemType.contactSubscriptionGroup:
        return bindContactSubscriptionGroupItem(
            item as PreferenceCenterContactSubscriptionGroupItem);
      case PreferenceCenterItemType.alert:
        return bindAlertItem(item as PreferenceCenterAlertItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preference Center'),
        elevation: 2,
      ),
      body: fullPreferenceCenterConfig == null
          ? const Center(child: CircularProgressIndicator())
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
    return Column(
      children: [
        item(indexPath),
        const Divider(height: 1, thickness: 0.5),
      ],
    );
  }

  @override
  bool shouldExistHeader() {
    return preferenceCenterConfig != null && 
           preferenceCenterConfig!.display != null;
  }

  @override
  Widget getHeader(BuildContext context) {
    final display = preferenceCenterConfig?.display;
    
    return Container(
      color: Colors.blueGrey.shade700,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          display?.title ?? '',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: display?.subtitle != null && display!.subtitle!.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(display.subtitle!),
              )
            : null,
      ),
    );
  }

  @override
  bool shouldExistSectionHeader(int section) {
    return preferenceCenterConfig?.sections[section].display != null;
  }

  @override
  Widget getSectionHeader(BuildContext context, int section) {
    final sectionData = preferenceCenterConfig?.sections[section];
    final display = sectionData?.display;
    
    return Container(
      color: Colors.cyan.shade700,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          display?.title ?? '',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: display?.subtitle != null && display!.subtitle!.isNotEmpty
            ? Text(display.subtitle!)
            : null,
      ),
    );
  }
}
