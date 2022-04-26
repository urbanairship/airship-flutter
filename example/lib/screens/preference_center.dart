import 'package:flutter/material.dart';
import 'package:airship_flutter/airship_flutter.dart';
import 'package:airship_example/styles.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PreferenceCenter extends StatefulWidget {
  @override
  _PreferenceCenterState createState() => _PreferenceCenterState();
}

class _PreferenceCenterState extends State<PreferenceCenter> {
  //RefreshController _refreshController = RefreshController(initialRefresh: false);
  List<String> activeChannelSubscriptions;
  Map<String, List<String>> activeContactSubscriptions;

  @override
  void initState() {
    initAirshipListeners();
    fillInSubscriptionList();
    Airship.trackScreen('Prefrence Center');
    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initAirshipListeners() async {
    Airship.onShowPreferenceCenter.listen((event) {
    });
  }

  void _onRefresh() async{
    //_refreshController.refreshCompleted();
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
    return activeChannelSubscriptions.where((f) => f == subscriptionId).toList().isNotEmpty;
  }

  bool isSubscribedContactSubscription (String subscriptionId) {
    return activeContactSubscriptions.containsKey(subscriptionId);
  }

  Future getPreferenceCenterConfig() async {
    PreferenceCenterConfig preferenceCenterConfig = await Airship.getPreferenceCenterConfig("pref");
    return preferenceCenterConfig;
  }

  void onPreferenceChannelItemToggled(PreferenceCenterChannelSubscriptionItem subscriptionItem, bool isSubscribed) {
    SubscriptionListEditor editor = Airship.editChannelSubscriptionLists();
    if (isSubscribed) {
      editor.subscribe(subscriptionItem.subscriptionId);
      activeChannelSubscriptions.add(subscriptionItem.subscriptionId);
    } else {
      editor.unsubscribe(subscriptionItem.subscriptionId);
      activeChannelSubscriptions.remove(subscriptionItem.subscriptionId);
    }
    editor.apply();
  }

  void onPreferenceContactSubscriptionItemToggled(PreferenceCenterContactSubscriptionItem subscriptionItem, List<String> scopes, bool isSubscribed) {
    ScopedSubscriptionListEditor editor = Airship.editContactSubscriptionLists();
    if (isSubscribed) {
      editor.subscribe(subscriptionItem.subscriptionId, scopes);
    } else {
      editor.unsubscribe(subscriptionItem.subscriptionId, scopes);
    }
    editor.apply();
  }

  @override
  Widget build(BuildContext context) {

    Widget bindChannelSubscriptionItem(PreferenceCenterChannelSubscriptionItem item) {
      return Dismissible(
        key: Key(UniqueKey().toString()),
        background: Container(color: Styles.airshipRed),
        child: SwitchListTile(
          title: Text('${item.display.title}', style:TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${item.display.subtitle}'),
          value: isSubscribedChannelSubscription(item.subscriptionId),
          onChanged: (bool value) {
            print('Mouna: onChanged $value');
            onPreferenceChannelItemToggled(item, value);
            setState(() {});
          },
        ),
      );
    }


    Widget bindContactSubscriptionItem(PreferenceCenterContactSubscriptionItem item) {
      return Dismissible(
        key: Key(UniqueKey().toString()),
        background: Container(color: Styles.airshipRed),
        child: SwitchListTile(
          title: Text('${item.display.title}', style:TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${item.display.subtitle}'),
          value: isSubscribedContactSubscription(item.subscriptionId),
          onChanged: (bool value) {
            onPreferenceContactSubscriptionItemToggled(item, [], value);
            setState(() {});
          },
        ),
      );
    }

    Widget bindContactSubscriptionGroupItem(PreferenceCenterContactSubscriptionGroupItem item) {
      return Dismissible(
        key: Key(UniqueKey().toString()),
        background: Container(color: Styles.airshipRed),
        child: SwitchListTile(
          title: Text('${item.display.title}', style:TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${item.display.subtitle}'),
        ),
      );
    }

    Widget bindAlertItem(PreferenceCenterAlertItem item) {
      return Dismissible(
        key: Key(UniqueKey().toString()),
        background: Container(color: Styles.airshipRed),
        child: SwitchListTile(
          title: Text('${item.display.title}', style:TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${item.display.subtitle}'),
        ),
      );
    }

    Widget _buildMessageList(List<PreferenceCenterItem> items) {
      return SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        header: MaterialClassicHeader(),
        //controller: _refreshController,
        //onRefresh: _onRefresh,
        child: ListView.builder(
          itemCount: items != null ? items.length : 0,
          itemBuilder: (context, index) {
            var item;
            switch (items[index].type) {
              case PreferenceCenterItemType.channelSubscription:
                return bindChannelSubscriptionItem(items[index] as PreferenceCenterChannelSubscriptionItem);
                break;
              case PreferenceCenterItemType.contactSubscription:
                return bindContactSubscriptionItem(items[index] as PreferenceCenterContactSubscriptionItem);
                break;
              case PreferenceCenterItemType.contactSubscriptionGroup:
                return bindContactSubscriptionGroupItem(items[index] as PreferenceCenterContactSubscriptionGroupItem);
                break;
              case PreferenceCenterItemType.alert:
                return bindAlertItem(items[index] as PreferenceCenterAlertItem);
                break;
            }
          },
        ),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Preference Center'),
          backgroundColor: Styles.borders,
        ),
        body: FutureBuilder(
          future: getPreferenceCenterConfig(),
          builder: (context, snapshot) {
            List<PreferenceCenterSection> list = [];

            if (snapshot.hasData) {
              list = snapshot.data.sections;
            }

            return SafeArea(
              bottom: false,
              child: Column(
                children: <Widget>[
                  for(var section in list )
                    _buildMessageList(section.items),
                ],
              ),
            );
          },
        )
    );
  }
}
