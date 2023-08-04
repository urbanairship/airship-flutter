import 'package:flutter/material.dart';
import 'package:airship_flutter/airship_flutter.dart';
import 'package:flutter_section_list/flutter_section_list.dart';

class PreferenceCenter extends StatefulWidget {
  @override
  _PreferenceCenterState createState() => _PreferenceCenterState();
}

class _PreferenceCenterState extends State<PreferenceCenter>
    with SectionAdapterMixin {
  String preferenceCenterId = "neat";
  PreferenceCenterConfig? preferenceCenterConfig;
  List<String> activeChannelSubscriptions = [];
  Map<String, List<ChannelScope>> activeContactSubscriptions =
      <String, List<ChannelScope>>{};

  @override
  void initState() {
    updatePreferenceCenterConfig();
    initAirshipListeners();
    fillInSubscriptionList();
    Airship.analytics.trackScreen('Preference Center');
    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initAirshipListeners() async {
    Airship.preferenceCenter.onDisplayPreferenceCenter.listen((event) {});
  }

  Future updatePreferenceCenterConfig() async {
    preferenceCenterConfig =
        await Airship.preferenceCenter.getConfig(preferenceCenterId);
    setState(() {});
  }

  void fillInSubscriptionList() async {
    var map = Map<String, ChannelScope>();
    map.addAll({
      "contact" : ChannelScope.app
    });
    Map<String, List<ChannelScope>> contactSubscriptionLists =
        await Airship.contact.getSubscriptionLists(map);
    List<String> channelSubscriptionLists =
    await Airship.channel.subscriptionLists;
    activeChannelSubscriptions =
        channelSubscriptionLists ?? [];

    contactSubscriptionLists.forEach((key, value) {
      activeContactSubscriptions[key] = value;
    });
    setState(() {});
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
    } else
      return false;
  }

  void onPreferenceChannelItemToggled(String subscriptionId, bool subscribe) {
    SubscriptionListEditor editor = Airship.channel.editSubscriptionLists();
    if (subscribe) {
      editor.subscribe(subscriptionId);
      activeChannelSubscriptions.add(subscriptionId);
    } else {
      editor.unsubscribe(subscriptionId);
      activeChannelSubscriptions.remove(subscriptionId);
    }
    editor.apply();
    setState(() {});
  }

  void applyContactSubscription(
      String subscriptionId, ChannelScope scope, bool subscribe) {
    List<ChannelScope> currentScopes =
        activeContactSubscriptions[subscriptionId] ?? [];
    List<ChannelScope> newScopes = [];
    if (subscribe) {
      newScopes = new List.from(currentScopes)..add(scope);
    } else {
      currentScopes.removeWhere((item) => scope == item);
      newScopes = currentScopes;
    }
    activeContactSubscriptions[subscriptionId] = newScopes;
  }

  void onPreferenceContactSubscriptionItemToggled(
      String subscriptionId, ChannelScope scope, bool subscribe) {
    ScopedSubscriptionListEditor editor =
        Airship.contact.editSubscriptionLists();
    if (subscribe) {
      editor.subscribe(subscriptionId, scope);
    } else {
      editor.unsubscribe(subscriptionId, scope);
    }
    editor.apply();
    applyContactSubscription(subscriptionId, scope, subscribe);
    setState(() {});
  }

  Widget bindChannelSubscriptionItem(
      PreferenceCenterChannelSubscriptionItem item) {
    return SwitchListTile(
        title: Text('${item.display.title}',
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${item.display.subtitle}'),
        value: isSubscribedChannelSubscription(item.subscriptionId),
        onChanged: (bool value) {
          onPreferenceChannelItemToggled(item.subscriptionId, value);
        });
  }

  Widget bindContactSubscriptionItem(
      PreferenceCenterContactSubscriptionItem item) {
    return SwitchListTile(
      title: Text('${item.display.title}',
          style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('${item.display.subtitle}'),
      value: isSubscribedContactSubscription(item.subscriptionId, []),
      onChanged: (bool value) {
        onPreferenceContactSubscriptionItemToggled(
            item.subscriptionId, ChannelScope.app, value);
      },
    );
  }

  List<ChannelScope> scopesFromComponents(List<ChannelScope> scopes) {
    List<ChannelScope> finalList = [];
    for (ChannelScope scope in scopes) {
      finalList.add(scope);
    }
    return finalList;
  }

  List<Widget> contactScopes(
      PreferenceCenterContactSubscriptionGroupItem item) {
    List<PreferenceCenterContactSubscriptionGroupItemComponent> components =
        item.components;
    List<Widget> widgets = [];
    for (PreferenceCenterContactSubscriptionGroupItemComponent component
        in components) {
      String? componentLabel = component.display.title;
      List<ChannelScope> scopes = component.scopes;
      Widget widget = FilterChip(
        avatar: CircleAvatar(
          backgroundColor: Colors.grey.shade800,
        ),
        label: Text('$componentLabel'),
        selected: isSubscribedContactSubscription(item.subscriptionId, scopes),
        onSelected: (bool value) {
          onPreferenceContactSubscriptionItemToggled(
              item.subscriptionId, ChannelScope.app, value);
        },
      );
      widgets.add(widget);
    }
    return widgets;
  }

  Widget bindContactSubscriptionGroupItem(
      PreferenceCenterContactSubscriptionGroupItem item) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text('${item.display.title}',
              style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${item.display.subtitle}'),
        ),
        Wrap(
          runAlignment: WrapAlignment.start,
          spacing: 10,
          children: contactScopes(item),
        ),
      ],
    );
  }

  Widget bindAlertItem(PreferenceCenterAlertItem item) {
    return ListTile(
      title: Text('${item.display.title}',
          style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('${item.display.subtitle}'),
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
        title: Text('Preference Center'),
      ),
      body: SectionListView.builder(adapter: this),
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
    return Container(
      child: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: <Widget>[item(indexPath), Divider(height: 0.5)],
      ),
    );
  }

  @override
  bool shouldExistHeader() {
    if (preferenceCenterConfig != null) {
      return true;
    }
    return false;
  }

  @override
  Widget getHeader(BuildContext context) {
    return Container(
      color: Colors.blueGrey,
      child: ListTile(
        title: Text('${preferenceCenterConfig?.display?.title ?? ''}',
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${preferenceCenterConfig?.display?.subtitle ?? ''}'),
      ),
    );
  }

  @override
  bool shouldExistSectionHeader(int section) {
    return preferenceCenterConfig?.sections[section] != null;
  }

  @override
  Widget getSectionHeader(BuildContext context, int section) {
    return Container(
      color: Colors.cyan,
      child: ListTile(
        title: Text(
            '${preferenceCenterConfig?.sections[section].display?.title ?? ''}',
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
            '${preferenceCenterConfig?.sections[section].display?.subtitle ?? ''}'),
      ),
    );
  }
}
