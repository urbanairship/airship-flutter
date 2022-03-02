import 'channel_scope.dart';

Map<String, dynamic> _toMap(dynamic json) {
  return Map<String, dynamic>.from(json);
}

List<Map<String, dynamic>> _toList(dynamic json) {
  return List<Map<String, dynamic>>.from(json);
}

class PreferenceCenterConfig {
  final String identifier;
  final PreferenceCenterCommonDisplay? display;
  final List<PreferenceCenterSection> sections;

  const PreferenceCenterConfig._internal(
      this.identifier, this.display, this.sections);

  static PreferenceCenterConfig? fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }

    try {
      var identifier = json["id"];
      var display = json["display"] != null ? PreferenceCenterCommonDisplay._fromJson(json["display"]) : null;
      var sections = PreferenceCenterSection._fromJsonList(_toList(json["sections"]));
      return PreferenceCenterConfig._internal(identifier, display, sections);
    } catch (e) {
      print("Invalid config: $e");
    }
  }

  @override
  String toString() {
    return "PreferenceCenterConfig(identifier=$identifier, display=$display, sections=$sections)";
  }
}

enum PreferenceCenterConditionType {
  notificationOptIn
}

class PreferenceCenterCondition {
  final PreferenceCenterConditionType? type = null;

  static List<PreferenceCenterCondition> _fromJsonList(List<Map<String, dynamic>> jsonList) {
    return jsonList.map((item) => PreferenceCenterCondition._fromJson(item)).toList();
  }

  static PreferenceCenterCondition _fromJson(Map<String, dynamic> json) {
      var type = json["type"];
      switch (type) {
        case "notification_opt_in":
          return PreferenceCenterNotificationOptInCondition._fromJson(json);
      }
      throw Exception("Invalid condition: " + type);
  }
}

enum PreferenceCenterConditionOptIn {
  optIn,
  optOut
}

class PreferenceCenterNotificationOptInCondition implements PreferenceCenterCondition {
  final PreferenceCenterConditionType type = PreferenceCenterConditionType.notificationOptIn;
  final PreferenceCenterConditionOptIn whenStatus;

  const PreferenceCenterNotificationOptInCondition._internal(this.whenStatus);

  static PreferenceCenterNotificationOptInCondition _fromJson(Map<String, dynamic> json) {
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
  String toString() {
    return "PreferenceCenterNotificationOptInCondition(whenStatus=$whenStatus)";
  }
}

class PreferenceCenterCommonDisplay {
  final String? title;
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

class PreferenceCenterIconDisplay implements PreferenceCenterCommonDisplay {
  final String? title;
  final String? subtitle;
  final String? icon;

  const PreferenceCenterIconDisplay._internal(this.title, this.subtitle, this.icon);

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

enum PreferenceCenterSectionType {
  common,
  labeledSectionBreak
}

class PreferenceCenterSection {
  final PreferenceCenterSectionType? type = null;
  final PreferenceCenterCommonDisplay? display = null;
  final List<PreferenceCenterItem>? items = null;
  final List<PreferenceCenterCondition>? conditions = null;

  static List<PreferenceCenterSection> _fromJsonList(List<Map<String, dynamic>> jsonList) {
    return jsonList.map((e) => _fromJson(e)).toList();
  }

  static PreferenceCenterSection _fromJson(Map<String, dynamic> json) {
    var type = json["type"];
    switch (type) {
      case "section":
        return PreferenceCenterCommonSection._fromJson(json);
      case "labeled_section_break":
        return PreferenceCenterLabeledSectionBreak._fromJson(json);
    }

    throw new Exception("Invalid section: " + type);
  }
}

class PreferenceCenterCommonSection implements PreferenceCenterSection {
  final PreferenceCenterSectionType type = PreferenceCenterSectionType.common;
  final PreferenceCenterCommonDisplay? display;
  final List<PreferenceCenterItem>? items;
  final List<PreferenceCenterCondition>? conditions;

  const PreferenceCenterCommonSection._internal(this.display, this.items, this.conditions);

  static PreferenceCenterCommonSection _fromJson(Map<String, dynamic> json) {
    var display = json["display"] != null ? PreferenceCenterCommonDisplay._fromJson(json["display"]) : null;
    var items = PreferenceCenterItem._fromJsonList(_toList(json["items"]));
    var conditions = json["conditions"] != null ? PreferenceCenterCondition._fromJsonList(_toList(json["conditions"])) : null;
    return PreferenceCenterCommonSection._internal(display, items, conditions);
  }

  @override
  String toString() {
    return "PreferenceCenterCommonSection(display=$display, items=$items, conditions=$conditions)";
  }
}

class PreferenceCenterLabeledSectionBreak implements PreferenceCenterSection {
  final PreferenceCenterSectionType type = PreferenceCenterSectionType.labeledSectionBreak;
  final PreferenceCenterCommonDisplay? display;
  final List<PreferenceCenterItem>? items = null;
  final List<PreferenceCenterCondition>? conditions;

  const PreferenceCenterLabeledSectionBreak._internal(this.display, this.conditions);

  static PreferenceCenterLabeledSectionBreak _fromJson(Map<String, dynamic> json) {
    var display = json["display"] != null ? PreferenceCenterCommonDisplay._fromJson(json["display"]) : null;
    var conditions = json["conditions"] != null ? PreferenceCenterCondition._fromJsonList(_toList(json["conditions"])) : null;
    return PreferenceCenterLabeledSectionBreak._internal(display, conditions);
  }

  @override
  String toString() {
    return "PreferenceCenterLabeledSectionBreak(display=$display, conditions=$conditions)";
  }
}

enum PreferenceCenterItemType {
  channelSubscription,
  contactSubscription,
  contactSubscriptionGroup,
  alert
}

class PreferenceCenterItem {
  final PreferenceCenterItemType? type = null;
  final PreferenceCenterCommonDisplay? display = null;
  final List<PreferenceCenterCondition>? conditions = null;

  static List<PreferenceCenterItem> _fromJsonList(List<Map<String, dynamic>> jsonList) {
    return jsonList.map((e) => _fromJson(e)).toList();
  }

  static PreferenceCenterItem _fromJson(Map<String, dynamic> json) {
    var type = json["type"];
    switch (type) {
      case "channel_subscription":
        return PreferenceCenterChannelSubscriptionItem._fromJson(json);
      case "contact_subscription":
        return PreferenceCenterContactSubscriptionItem._fromJson(json);
      case "contact_subscription_group":
        return PreferenceCenterContactSubscriptionGroupItem._fromJson(json);
      case "alert":
        return PreferenceCenterAlertItem._fromJson(json);
    }
    throw new Exception("Invalid item: " + type);
  }
}

class PreferenceCenterAlertItemButton {
  final String text;
  final String? contentDescription;
  final Map<String, dynamic> actions;

  const PreferenceCenterAlertItemButton._internal(this.text, this.contentDescription, this.actions);

  static PreferenceCenterAlertItemButton _fromJson(Map<String, dynamic> json) {
    var text = json["text"];
    var contentDescription = json["content_description"];
    var actions = json["actions"];

    return PreferenceCenterAlertItemButton._internal(text, contentDescription, actions);
  }

  @override
  String toString() {
    return "PreferenceCenterAlertItemButton(text=$text, contentDescription=$contentDescription, action=$actions)";
  }
}

class PreferenceCenterAlertItem implements PreferenceCenterItem {
  final PreferenceCenterItemType type = PreferenceCenterItemType.alert;
  final PreferenceCenterIconDisplay display;
  final PreferenceCenterAlertItemButton? button;
  final List<PreferenceCenterCondition>? conditions;

  const PreferenceCenterAlertItem._internal(this.display, this.button, this.conditions);

  static PreferenceCenterAlertItem _fromJson(Map<String, dynamic> json) {
    var display = PreferenceCenterIconDisplay._fromJson(json["display"]);
    var button = json["button"] != null ? PreferenceCenterAlertItemButton._fromJson(_toMap(json["button"])) : null;
    var conditions = json["conditions"] != null ? PreferenceCenterCondition._fromJsonList(_toList(json["conditions"])) : null;
    return PreferenceCenterAlertItem._internal(display, button, conditions);
  }

  @override
  String toString() {
    return "PreferenceCenterAlertItem(display=$display, button=$button, conditions=$conditions)";
  }
}

class PreferenceCenterChannelSubscriptionItem implements PreferenceCenterItem {
  final PreferenceCenterItemType type = PreferenceCenterItemType.channelSubscription;
  final PreferenceCenterCommonDisplay display;
  final String subscriptionId;
  final List<PreferenceCenterCondition>? conditions;

  const PreferenceCenterChannelSubscriptionItem._internal(this.display, this.subscriptionId, this.conditions);

  static PreferenceCenterChannelSubscriptionItem _fromJson(Map<String, dynamic> json) {
    var display = PreferenceCenterIconDisplay._fromJson(json["display"]);
    var subscriptionId = json["subscription_id"];
    var conditions = json["conditions"] != null ? PreferenceCenterCondition._fromJsonList(_toList(json["conditions"])) : null;
    return PreferenceCenterChannelSubscriptionItem._internal(display, subscriptionId, conditions);
  }

  @override
  String toString() {
    return "PreferenceCenterChannelSubscriptionItem(display=$display, subscriptionId=$subscriptionId, conditions=$conditions)";
  }
}

class PreferenceCenterContactSubscriptionItem implements PreferenceCenterItem {
  final PreferenceCenterItemType type = PreferenceCenterItemType.contactSubscription;
  final PreferenceCenterCommonDisplay display;
  final String subscriptionId;
  final List<PreferenceCenterCondition>? conditions;

  const PreferenceCenterContactSubscriptionItem._internal(this.display, this.subscriptionId, this.conditions);

  static PreferenceCenterContactSubscriptionItem _fromJson(Map<String, dynamic> json) {
    var display = PreferenceCenterIconDisplay._fromJson(json["display"]);
    var subscriptionId = json["subscription_id"];
    var conditions = json["conditions"] != null ? PreferenceCenterCondition._fromJsonList(_toList(json["conditions"])) : null;
    return PreferenceCenterContactSubscriptionItem._internal(display, subscriptionId, conditions);
  }

  @override
  String toString() {
    return "PreferenceCenterContactSubscriptionItem(display=$display, subscriptionId=$subscriptionId, conditions=$conditions)";
  }
}


class PreferenceCenterContactSubscriptionGroupItemComponent {
  final List<ChannelScope> scopes;
  final PreferenceCenterCommonDisplay display;

  const PreferenceCenterContactSubscriptionGroupItemComponent._internal(this.scopes, this.display);

  static List<PreferenceCenterContactSubscriptionGroupItemComponent> _fromJsonList(List<Map<String, dynamic>> jsonList) {
    return jsonList.map((e) => _fromJson(e)).toList();
  }

  static PreferenceCenterContactSubscriptionGroupItemComponent _fromJson(Map<String, dynamic> json) {
    var scopes = List<String>.from(json["scopes"]).map((scopeString) => _parseScope(scopeString)).toList();
    var display = PreferenceCenterCommonDisplay._fromJson(json["display"]);

    return PreferenceCenterContactSubscriptionGroupItemComponent._internal(scopes, display);
  }

  static ChannelScope _parseScope(String scopeString) {
    switch(scopeString.toLowerCase()) {
      case "app": return ChannelScope.app;
      case "web": return ChannelScope.web;
      case "email": return ChannelScope.email;
      case "sms": return ChannelScope.sms;
    }
    throw Exception("Invalid scope: $scopeString");
  }

  @override
  String toString() {
    return "PreferenceCenterContactSubscriptionGroupItemComponent(scopes=$scopes, display=$display)";
  }
}

class PreferenceCenterContactSubscriptionGroupItem implements PreferenceCenterItem {
  final PreferenceCenterItemType type = PreferenceCenterItemType.contactSubscriptionGroup;
  final PreferenceCenterCommonDisplay display;
  final String subscriptionId;
  final List<PreferenceCenterCondition>? conditions;
  final List<PreferenceCenterContactSubscriptionGroupItemComponent> components;

  const PreferenceCenterContactSubscriptionGroupItem._internal(this.display, this.subscriptionId, this.conditions, this.components);

  static PreferenceCenterContactSubscriptionGroupItem _fromJson(Map<String, dynamic> json) {
    var display = PreferenceCenterIconDisplay._fromJson(json["display"]);
    var subscriptionId = json["subscription_id"];
    var conditions = json["conditions"] != null ? PreferenceCenterCondition._fromJsonList(_toList(json["conditions"])) : null;
    var components =
    PreferenceCenterContactSubscriptionGroupItemComponent._fromJsonList(_toList(json["components"]));

    return PreferenceCenterContactSubscriptionGroupItem._internal(display, subscriptionId, conditions, components);
  }

  @override
  String toString() {
    return "PreferenceCenterContactSubscriptionGroupItem(display=$display, subscriptionId=$subscriptionId, conditions=$conditions, components=$components)";
  }
}