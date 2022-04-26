import 'package:flutter/material.dart';
import 'package:airship_flutter/airship_flutter.dart';
import 'package:airship_example/styles.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_section_list/flutter_section_list.dart';

class PreferenceCenter extends StatefulWidget {
  @override
  _PreferenceCenterState createState() => _PreferenceCenterState();
}

class _PreferenceCenterState extends State<PreferenceCenter>  with SectionAdapterMixin{

  PreferenceCenterConfig preferenceCenterConfig;
  List<String> activeChannelSubscriptions;
  Map<String, List<String>> activeContactSubscriptions;

  @override
  void initState() {
    initAirshipListeners();
    updatePreferenceCenterConfig();
    fillInSubscriptionList();
    Airship.trackScreen('Prefrence Center');
    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initAirshipListeners() async {
    Airship.onShowPreferenceCenter.listen((event) {
    });
  }

  void fillInSubscriptionList() async {
    SubscriptionList subscriptionList = await Airship.getSubscriptionLists(["channel", "contact"]);
    activeChannelSubscriptions = subscriptionList.channelSubscriptionLists;
    var contactSubscriptionLists = subscriptionList.contactSubscriptionLists;
    for (ContactSubscriptionList contact in contactSubscriptionLists) {
      activeContactSubscriptions[contact.identifier] = contact.scopes;
    }
  }
  bool isSubscribedChannelSubscription (String subscriptionId) {
    if (activeChannelSubscriptions != null) {
      return activeChannelSubscriptions.contains(subscriptionId);
    }
    return false;
  }

  bool isSubscribedContactSubscription (String subscriptionId, List<String> scopes) {
    print('MounaLog activeContactSubscriptions $activeContactSubscriptions');
    if (activeContactSubscriptions != null) {
      if (scopes.isEmpty) {
        return activeContactSubscriptions.containsKey(subscriptionId);
      }
      List<String> activeContactSubscriptionsScopes = activeContactSubscriptions[subscriptionId];
      return activeContactSubscriptionsScopes.contains(scopes);
    }
    return false;
  }

  Future updatePreferenceCenterConfig() async {
    PreferenceCenterConfig config = await Airship.getPreferenceCenterConfig("neat");
    setState(() {
      preferenceCenterConfig = config;
    });
  }

  void onPreferenceChannelItemToggled(String subscriptionId, bool isSubscribed) {
    SubscriptionListEditor editor = Airship.editChannelSubscriptionLists();
    if (isSubscribed) {
      editor.subscribe(subscriptionId);
      activeChannelSubscriptions.add(subscriptionId);
    } else {
      editor.unsubscribe(subscriptionId);
      activeChannelSubscriptions.remove(subscriptionId);
    }
    editor.apply();
    setState(() {});
  }

  void onPreferenceContactSubscriptionItemToggled(String subscriptionId, List<String> scopes, bool isSubscribed) {
    ScopedSubscriptionListEditor editor = Airship.editContactSubscriptionLists();
    if (isSubscribed) {
      editor.subscribe(subscriptionId, scopes);
      activeContactSubscriptions.putIfAbsent(subscriptionId, () => scopes);
    } else {
      editor.unsubscribe(subscriptionId, scopes);
      activeContactSubscriptions.remove(subscriptionId);
    }
    editor.apply();
    //setState(() {});
  }

  Widget bindChannelSubscriptionItem(PreferenceCenterChannelSubscriptionItem item) {
    return SwitchListTile(
        title: Text('${item.display.title}', style:TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${item.display.subtitle}'),
        value: isSubscribedChannelSubscription(item.subscriptionId),
        onChanged: (bool value) {
          onPreferenceChannelItemToggled(item.subscriptionId, value);
        }
    );
  }


  Widget bindContactSubscriptionItem(PreferenceCenterContactSubscriptionItem item) {
    return SwitchListTile(
        title: Text('${item.display.title}', style:TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${item.display.subtitle}'),
        value: isSubscribedContactSubscription(item.subscriptionId, []),
        onChanged: (bool value) {
          onPreferenceContactSubscriptionItemToggled(item.subscriptionId, [], value);
        },
    );
  }

  List<String> scopesFromComponents (List<ChannelScope> scopes) {
    List<String> finalList = [];
    for (ChannelScope scope in scopes) {
      finalList.add(scope.toString().split('.').last);
    }
    return finalList;
  }

  List<Widget> contactScopes(PreferenceCenterContactSubscriptionGroupItem item) {
    List<PreferenceCenterContactSubscriptionGroupItemComponent> components = item.components;
    List<Widget> widgets = [];
    for (PreferenceCenterContactSubscriptionGroupItemComponent component in components) {
      String componentLabel = component.display.title;
      List<String> scopes = scopesFromComponents(component.scopes);
      Widget widget = FilterChip(
        avatar: CircleAvatar(
          backgroundColor: Colors.grey.shade800,
        ),
        label: Text('$componentLabel'),
        selected: isSubscribedContactSubscription(item.subscriptionId, scopes),
        onSelected: (bool value) {
          onPreferenceContactSubscriptionItemToggled(item.subscriptionId, scopes, value);
        },
      );
      widgets.add(widget);
    }
    return widgets;
  }

  Widget bindContactSubscriptionGroupItem(PreferenceCenterContactSubscriptionGroupItem item) {
    return Column(
        children: <Widget>[
          ListTile(
            title: Text('${item.display.title}', style:TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${item.display.subtitle}'),
          ),
          Wrap(
            runAlignment : WrapAlignment.start,
            spacing: 10,
            children: contactScopes(item),
          ),
        ],
    );
  }

  Widget bindAlertItem(PreferenceCenterAlertItem item) {
    return ListTile(
        title: Text('${item.display.title}', style:TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${item.display.subtitle}'),
    );
  }

  Widget item(IndexPath indexPath) {
    List<PreferenceCenterItem> items = preferenceCenterConfig.sections[indexPath.section].items;
    PreferenceCenterItem item = items[indexPath.item];
    switch (item.type) {
      case PreferenceCenterItemType.channelSubscription:
        return bindChannelSubscriptionItem(item as PreferenceCenterChannelSubscriptionItem);
        break;
      case PreferenceCenterItemType.contactSubscription:
        return bindContactSubscriptionItem(item as PreferenceCenterContactSubscriptionItem);
        break;
      case PreferenceCenterItemType.contactSubscriptionGroup:
        return bindContactSubscriptionGroupItem(item as PreferenceCenterContactSubscriptionGroupItem);
        break;
      case PreferenceCenterItemType.alert:
        return bindAlertItem(item as PreferenceCenterAlertItem);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Preference Center'),),
      body: SectionListView.builder(adapter: this),
    );
  }

  @override
  int numberOfSections() {
    if (preferenceCenterConfig != null) {
      int numberOfSections = preferenceCenterConfig.sections.length;
      return numberOfSections;
    }
    return 0;
  }

  @override
  int numberOfItems(int section) {
    if (preferenceCenterConfig != null) {
      return preferenceCenterConfig.sections[section].items.length;
    }
    return 0;
  }

  @override
  Widget getItem(BuildContext context, IndexPath indexPath) {
    return Container(
      child: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: <Widget>[
          item(indexPath),
          Divider(height: 0.5,)
        ],
      ),
    );
  }

  @override
  bool shouldExistSectionHeader(int section) {
    return true;
  }

  @override
  bool shouldSectionHeaderStick(int section) {
    if (preferenceCenterConfig.display != null) {
      return true;
    }
    return false;
  }

  @override
  Widget getSectionHeader(BuildContext context, int section) {
    return Container(
        key: GlobalKey(debugLabel: 'header $section'),
        color: Colors.blue,
        child: ListTile(
          title: Text('${preferenceCenterConfig.display.title ?? ''}', style:TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${preferenceCenterConfig.display.subtitle ?? ''}'),
        ),
    );
  }

}
