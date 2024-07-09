import 'channel_scope.dart';
import 'airship_utils.dart';

Map<String, dynamic> _toMap(dynamic json) {
  return Map<String, dynamic>.from(json);
}

List<Map<String, dynamic>> _toList(List<dynamic> json) {
  List<Map<String, dynamic>> list = [];
  json.forEach((element) => list.add(_toMap(element)));
  return list;
}

/// Preference center config object.
class PreferenceCenterConfig {
  /// The ID of the preference center.
  final String identifier;

  /// The preference center [PreferenceCenterCommonDisplay].
  final PreferenceCenterCommonDisplay? display;

  /// The preference center list of [PreferenceCenterSection].
  final List<PreferenceCenterSection> sections;

  const PreferenceCenterConfig._internal(
      this.identifier, this.display, this.sections);

  static PreferenceCenterConfig? fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }

    try {
      var identifier = json["id"];
      var display = json["display"] != null
          ? PreferenceCenterCommonDisplay._fromJson(_toMap(json["display"]))
          : null;
      var sections = PreferenceCenterSection._fromJsonList(_toList(json["sections"]));
      return PreferenceCenterConfig._internal(identifier, display, sections);
    } catch (e, s) {
      print("Invalid config: $e");
      print("Stack trace:\n$s");
    }
    return null;
  }

  PreferenceCenterConfig copy(List<PreferenceCenterSection> sections) {
    return PreferenceCenterConfig._internal(this.identifier, this.display, sections);
  }

  @override
  String toString() {
    return "PreferenceCenterConfig(identifier=$identifier, display=$display, sections=$sections)";
  }
}

/// Preference center condition state.
class PreferenceCenterConditionState {
  /// Notification opt-in status.
  final bool notificationOptIn;

  PreferenceCenterConditionState(this.notificationOptIn);
}

/// Preference center condition type.
enum PreferenceCenterConditionType { notificationOptIn }

/// Preference center condition.
abstract class PreferenceCenterCondition {
  /// The condition type.
  final PreferenceCenterConditionType? type = null;

  static List<PreferenceCenterCondition> _fromJsonList(
      List<Map<String, dynamic>> jsonList) {
    return jsonList
        .map((item) => PreferenceCenterCondition._fromJson(item))
        .toList();
  }

  static PreferenceCenterCondition _fromJson(Map<String, dynamic> json) {
    var type = json["type"];
    switch (type) {
      case "notification_opt_in":
        return PreferenceCenterNotificationOptInCondition._fromJson(_toMap(json));
    }
    throw Exception("Invalid condition: " + type);
  }

  bool evaluate(PreferenceCenterConditionState state);
}

/// Preference center condition opt-in.
enum PreferenceCenterConditionOptIn { optIn, optOut }

/// Preference center notification opt-in condition.
class PreferenceCenterNotificationOptInCondition
    implements PreferenceCenterCondition {
  /// The condition type.
  final PreferenceCenterConditionType type =
      PreferenceCenterConditionType.notificationOptIn;

  /// The condition opt-in status.
  final PreferenceCenterConditionOptIn whenStatus;

  const PreferenceCenterNotificationOptInCondition._internal(this.whenStatus);

  static PreferenceCenterNotificationOptInCondition _fromJson(
      Map<String, dynamic> json) {
    var whenStatus = PreferenceCenterConditionOptIn.optIn;
    switch (json["when_status"]) {
      case "opt_in":
        whenStatus = PreferenceCenterConditionOptIn.optIn;
        break;
      case "opt_out":
        whenStatus = PreferenceCenterConditionOptIn.optOut;
        break;
      default:
        throw new Exception("Invalid status: " + json["when_status"]);
    }

    return PreferenceCenterNotificationOptInCondition._internal(whenStatus);
  }

  @override
  bool evaluate(PreferenceCenterConditionState state) {
    return state.notificationOptIn ==
        (whenStatus == PreferenceCenterConditionOptIn.optIn);
  }

  @override
  String toString() {
    return "PreferenceCenterNotificationOptInCondition(whenStatus=$whenStatus)";
  }
}

/// Preference center common display information.
class PreferenceCenterCommonDisplay {
  /// The display title.
  final String? title;

  /// The display subtitle.
  final String? subtitle;

  const PreferenceCenterCommonDisplay._internal(this.title, this.subtitle);

  static PreferenceCenterCommonDisplay _fromJson(Map<String, dynamic> json) {
    var title = json["name"];
    var subtitle = json["description"];
    return PreferenceCenterCommonDisplay._internal(title, subtitle);
  }

  @override
  String toString() {
    return "PreferenceCenterCommonDisplay(title=$title, subtitle=$subtitle)";
  }
}

/// Preference center common display information with icon.
class PreferenceCenterIconDisplay implements PreferenceCenterCommonDisplay {
  /// The display title.
  final String? title;

  /// The display subtitle.
  final String? subtitle;

  /// The display icon.
  final String? icon;

  const PreferenceCenterIconDisplay._internal(
      this.title, this.subtitle, this.icon);

  static PreferenceCenterIconDisplay _fromJson(Map<String, dynamic> json) {
    var title = json["name"];
    var subtitle = json["description"];
    var icon = json["icon"];
    return PreferenceCenterIconDisplay._internal(title, subtitle, icon);
  }

  @override
  String toString() {
    return "PreferenceCenterIconDisplay(title=$title, subtitle=$subtitle, icon=$icon)";
  }
}

/// Preference center section type.
enum PreferenceCenterSectionType { common, labeledSectionBreak }

/// Preference center section.
abstract class PreferenceCenterSection {
  /// The section type.
  PreferenceCenterSectionType get type;

  /// The common display information.
  PreferenceCenterCommonDisplay? get display;

  /// A list of preference center items.
  List<PreferenceCenterItem>? get items;

  /// A list of preference center conditions.
  List<PreferenceCenterCondition>? get conditions;

  PreferenceCenterSection copy(List<PreferenceCenterItem> items);

  bool evaluateConditions(PreferenceCenterConditionState state);

  static List<PreferenceCenterSection> _fromJsonList(
      List<Map<String, dynamic>> jsonList) {
    return jsonList.map((e) => _fromJson(e)).toList();
  }

  static PreferenceCenterSection _fromJson(Map<String, dynamic> json) {
    var type = json["type"];
    switch (type) {
      case "section":
        return PreferenceCenterCommonSection._fromJson(_toMap(json));
      case "labeled_section_break":
        return PreferenceCenterLabeledSectionBreak._fromJson(_toMap(json));
    }
    throw new Exception("Invalid section: " + type);
  }
}

/// Preference center common section.
class PreferenceCenterCommonSection implements PreferenceCenterSection {
  /// The section type.
  @override
  final PreferenceCenterSectionType type = PreferenceCenterSectionType.common;

  /// The common display information.
  @override
  final PreferenceCenterCommonDisplay? display;

  /// A list of preference center items.
  @override
  final List<PreferenceCenterItem>? items;

  /// A list of preference center conditions.
  @override
  final List<PreferenceCenterCondition>? conditions;

  @override
  bool evaluateConditions(PreferenceCenterConditionState state) {
    if (conditions == null || conditions!.isEmpty) {
      return true;
    }
    for (var condition in conditions!) {
      if (!condition.evaluate(state)) {
        return false;
      }
    }
    return true;
  }

  const PreferenceCenterCommonSection._internal(
      this.display, this.items, this.conditions);

  @override
  PreferenceCenterCommonSection copy(List<PreferenceCenterItem>? items) {
    return PreferenceCenterCommonSection._internal(
        this.display, items, this.conditions);
  }

  static PreferenceCenterCommonSection _fromJson(Map<String, dynamic> json) {
    var display = json["display"] != null
        ? PreferenceCenterCommonDisplay._fromJson(_toMap(json["display"]))
        : null;
    var items = PreferenceCenterItem._fromJsonList(_toList(json["items"]));
    var conditions = json["conditions"] != null
        ? PreferenceCenterCondition._fromJsonList(_toList(json["conditions"]))
        : null;
    return PreferenceCenterCommonSection._internal(display, items, conditions);
  }

  @override
  String toString() {
    return "PreferenceCenterCommonSection(display=$display, items=$items, conditions=$conditions)";
  }
}

class PreferenceCenterLabeledSectionBreak implements PreferenceCenterSection {
  /// The section type.
  @override
  final PreferenceCenterSectionType type =
      PreferenceCenterSectionType.labeledSectionBreak;

  /// The common display information.
  @override
  final PreferenceCenterCommonDisplay? display;

  /// A list of preference center items.
  @override
  final List<PreferenceCenterItem>? items = null;

  /// A list of preference center conditions.
  @override
  final List<PreferenceCenterCondition>? conditions;

  const PreferenceCenterLabeledSectionBreak._internal(
      this.display, this.conditions);

  @override
  PreferenceCenterLabeledSectionBreak copy(List<PreferenceCenterItem>? items) {
    return PreferenceCenterLabeledSectionBreak._internal(
        this.display, this.conditions);
  }

  @override
  bool evaluateConditions(PreferenceCenterConditionState state) {
    if (conditions == null || conditions!.isEmpty) {
      return true;
    }
    for (var condition in conditions!) {
      if (!condition.evaluate(state)) {
        return false;
      }
    }
    return true;
  }

  static PreferenceCenterLabeledSectionBreak _fromJson(
      Map<String, dynamic> json) {
    var display = json["display"] != null
        ? PreferenceCenterCommonDisplay._fromJson(_toMap(json["display"]))
        : null;
    var conditions = json["conditions"] != null
        ? PreferenceCenterCondition._fromJsonList(_toList(json["conditions"]))
        : null;
    return PreferenceCenterLabeledSectionBreak._internal(display, conditions);
  }

  @override
  String toString() {
    return "PreferenceCenterLabeledSectionBreak(display=$display, conditions=$conditions)";
  }
}

/// Preference center item type.
enum PreferenceCenterItemType {
  channelSubscription,
  contactSubscription,
  contactSubscriptionGroup,
  alert
}

/// Preference center item.
abstract class PreferenceCenterItem {
  /// The item type.
  PreferenceCenterItemType get type;

  /// The common display information.
  PreferenceCenterCommonDisplay get display;

  /// A list of preference center conditions.
  List<PreferenceCenterCondition>? get conditions;

  bool evaluateConditions(PreferenceCenterConditionState state) {
    if (conditions == null || conditions!.isEmpty) {
      return true;
    }
    for (var condition in conditions!) {
      if (!condition.evaluate(state)) {
        return false;
      }
    }
    return true;
  }

  static List<PreferenceCenterItem> _fromJsonList(
      List<Map<String, dynamic>> jsonList) {
    return jsonList.map((e) => _fromJson(e)).toList();
  }

  static PreferenceCenterItem _fromJson(Map<String, dynamic> json) {
    var type = json["type"];
    switch (type) {
      case "channel_subscription":
        return PreferenceCenterChannelSubscriptionItem._fromJson(_toMap(json));
      case "contact_subscription":
        return PreferenceCenterContactSubscriptionItem._fromJson(_toMap(json));
      case "contact_subscription_group":
        return PreferenceCenterContactSubscriptionGroupItem._fromJson(_toMap(json));
      case "alert":
        return PreferenceCenterAlertItem._fromJson(_toMap(json));
    }
    throw new Exception("Invalid item: " + type);
  }
}

/// Preference center alert item button.
class PreferenceCenterAlertItemButton {
  /// The alert item button text.
  final String text;

  /// The alert item button content description.
  final String? contentDescription;

  /// The alert item button actions.
  final Map<String, dynamic> actions;

  const PreferenceCenterAlertItemButton._internal(
      this.text, this.contentDescription, this.actions);

  static PreferenceCenterAlertItemButton _fromJson(Map<String, dynamic> json) {
    var text = json["text"];
    var contentDescription = json["content_description"];
    var actions = _toMap(json["actions"]);

    return PreferenceCenterAlertItemButton._internal(
        text, contentDescription, actions);
  }

  @override
  String toString() {
    return "PreferenceCenterAlertItemButton(text=$text, contentDescription=$contentDescription, action=$actions)";
  }
}

/// Preference center alert item.
class PreferenceCenterAlertItem implements PreferenceCenterItem {
  /// The alert item type.
  @override
  final PreferenceCenterItemType type = PreferenceCenterItemType.alert;

  /// The alert item icon display information.
  @override
  final PreferenceCenterIconDisplay display;

  /// A list of preference center condition.
  @override
  final List<PreferenceCenterCondition>? conditions;

  /// The alert item button.
  final PreferenceCenterAlertItemButton? button;

  const PreferenceCenterAlertItem._internal(
      this.display, this.button, this.conditions);

  @override
  bool evaluateConditions(PreferenceCenterConditionState state) {
    if (conditions == null || conditions!.isEmpty) {
      return true;
    }
    for (var condition in conditions!) {
      if (!condition.evaluate(state)) {
        return false;
      }
    }
    return true;
  }

  static PreferenceCenterAlertItem _fromJson(Map<String, dynamic> json) {
    var display = PreferenceCenterIconDisplay._fromJson(_toMap(json["display"]));
    var button = json["button"] != null
        ? PreferenceCenterAlertItemButton._fromJson(_toMap(json["button"]))
        : null;
    var conditions = json["conditions"] != null
        ? PreferenceCenterCondition._fromJsonList(_toList(json["conditions"]))
        : null;
    return PreferenceCenterAlertItem._internal(display, button, conditions);
  }

  @override
  String toString() {
    return "PreferenceCenterAlertItem(display=$display, button=$button, conditions=$conditions)";
  }
}

/// Preference center channel subscription item.
class PreferenceCenterChannelSubscriptionItem implements PreferenceCenterItem {
  /// The channel subscription item type.
  @override
  final PreferenceCenterItemType type =
      PreferenceCenterItemType.channelSubscription;

  /// The channel subscription item common display information.
  @override
  final PreferenceCenterCommonDisplay display;

  /// A list of preference center condition.
  @override
  final List<PreferenceCenterCondition>? conditions;

  /// The subscription list id.
  final String subscriptionId;

  const PreferenceCenterChannelSubscriptionItem._internal(
      this.display, this.subscriptionId, this.conditions);

  @override
  bool evaluateConditions(PreferenceCenterConditionState state) {
    if (conditions == null || conditions!.isEmpty) {
      return true;
    }
    for (var condition in conditions!) {
      if (!condition.evaluate(state)) {
        return false;
      }
    }
    return true;
  }

  static PreferenceCenterChannelSubscriptionItem _fromJson(
      Map<String, dynamic> json) {
    var display = PreferenceCenterIconDisplay._fromJson(_toMap(json["display"]));
    var subscriptionId = json["subscription_id"];
    var conditions = json["conditions"] != null
        ? PreferenceCenterCondition._fromJsonList(_toList(json["conditions"]))
        : null;
    return PreferenceCenterChannelSubscriptionItem._internal(
        display, subscriptionId, conditions);
  }

  @override
  String toString() {
    return "PreferenceCenterChannelSubscriptionItem(display=$display, subscriptionId=$subscriptionId, conditions=$conditions)";
  }
}

/// Preference center contact subscription item.
class PreferenceCenterContactSubscriptionItem implements PreferenceCenterItem {
  /// The contact subscription item type.
  @override
  final PreferenceCenterItemType type =
      PreferenceCenterItemType.contactSubscription;

  /// The contact subscription item common display information.
  @override
  final PreferenceCenterCommonDisplay display;

  /// A list of preference center condition.
  @override
  final List<PreferenceCenterCondition>? conditions;

  /// The subscription list id.
  final String subscriptionId;

  /// The channel scopes.
  final List<ChannelScope> scopes;

  const PreferenceCenterContactSubscriptionItem._internal(
      this.display, this.subscriptionId, this.conditions, this.scopes);

  @override
  bool evaluateConditions(PreferenceCenterConditionState state) {
    if (conditions == null || conditions!.isEmpty) {
      return true;
    }
    for (var condition in conditions!) {
      if (!condition.evaluate(state)) {
        return false;
      }
    }
    return true;
  }

  static PreferenceCenterContactSubscriptionItem _fromJson(
      Map<String, dynamic> json) {
    var display = PreferenceCenterIconDisplay._fromJson(_toMap(json["display"]));
    var subscriptionId = json["subscription_id"];
    var conditions = json["conditions"] != null
        ? PreferenceCenterCondition._fromJsonList(_toList(json["conditions"]))
        : null;
    var scopes = List<String>.from(json["scopes"])
        .map((scopeString) => AirshipUtils.parseChannelScope(scopeString))
        .toList();
    return PreferenceCenterContactSubscriptionItem._internal(
        display, subscriptionId, conditions, scopes);
  }

  @override
  String toString() {
    return "PreferenceCenterContactSubscriptionItem(display=$display, subscriptionId=$subscriptionId, conditions=$conditions, scopes=$scopes)";
  }
}

/// Preference center contact subscription group item component.
class PreferenceCenterContactSubscriptionGroupItemComponent {
  /// The channel scopes.
  final List<ChannelScope> scopes;

  /// The contact subscription group item common display information.
  final PreferenceCenterCommonDisplay display;

  const PreferenceCenterContactSubscriptionGroupItemComponent._internal(
      this.scopes, this.display);

  static List<PreferenceCenterContactSubscriptionGroupItemComponent>
      _fromJsonList(List<Map<String, dynamic>> jsonList) {
    return jsonList.map((e) => _fromJson(e)).toList();
  }

  static PreferenceCenterContactSubscriptionGroupItemComponent _fromJson(
      Map<String, dynamic> json) {
    var scopes = List<String>.from(json["scopes"])
        .map((scopeString) => AirshipUtils.parseChannelScope(scopeString))
        .toList();
    var display = PreferenceCenterCommonDisplay._fromJson(_toMap(json["display"]));

    return PreferenceCenterContactSubscriptionGroupItemComponent._internal(
        scopes, display);
  }

  @override
  String toString() {
    return "PreferenceCenterContactSubscriptionGroupItemComponent(scopes=$scopes, display=$display)";
  }
}

/// Preference center contact subscription group item.
class PreferenceCenterContactSubscriptionGroupItem
    implements PreferenceCenterItem {
  /// The contact subscription group item type.
  @override
  final PreferenceCenterItemType type =
      PreferenceCenterItemType.contactSubscriptionGroup;

  /// The contact subscription group item common display information.
  @override
  final PreferenceCenterCommonDisplay display;

  /// A list of preference center condition.
  @override
  final List<PreferenceCenterCondition>? conditions;

  /// The subscription list id.
  final String subscriptionId;

  /// A list of subscription group item component.
  final List<PreferenceCenterContactSubscriptionGroupItemComponent> components;

  const PreferenceCenterContactSubscriptionGroupItem._internal(
      this.display, this.subscriptionId, this.conditions, this.components);

  @override
  bool evaluateConditions(PreferenceCenterConditionState state) {
    if (conditions == null || conditions!.isEmpty) {
      return true;
    }
    for (var condition in conditions!) {
      if (!condition.evaluate(state)) {
        return false;
      }
    }
    return true;
  }

  static PreferenceCenterContactSubscriptionGroupItem _fromJson(
      Map<String, dynamic> json) {
    var display = PreferenceCenterIconDisplay._fromJson(_toMap(json["display"]));
    var subscriptionId = json["subscription_id"];
    var conditions = json["conditions"] != null
        ? PreferenceCenterCondition._fromJsonList(_toList(json["conditions"]))
        : null;
    var components =
        PreferenceCenterContactSubscriptionGroupItemComponent._fromJsonList(
            _toList(json["components"]));

    return PreferenceCenterContactSubscriptionGroupItem._internal(
        display, subscriptionId, conditions, components);
  }

  @override
  String toString() {
    return "PreferenceCenterContactSubscriptionGroupItem(display=$display, subscriptionId=$subscriptionId, conditions=$conditions, components=$components)";
  }
}
