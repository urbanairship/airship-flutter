import "feature.dart";
import "channel_scope.dart";

class AirshipUtils {
  static List<Feature> parseFeatures(List<String> strings) {
    var features = <Feature>[];
    strings.forEach((element) {
      switch (element) {
        case "push": features.add(Feature.push); break;
        case "analytics": features.add(Feature.analytics); break;
        case "in_app_automation": features.add(Feature.inAppAutomation); break;
        case "tags_and_attributes": features.add(Feature.tagsAndAttributes); break;
        case "message_center": features.add(Feature.messageCenter); break;
        case "contacts": features.add(Feature.contacts); break;
        default: print("Invalid feature: $element");
      }
    });
    return features;
  }

  static List<String> toFeatureStringList(List<Feature> features) {
    var strings = <String>[];
    features.forEach((element) {
      switch (element) {
        case Feature.push: strings.add("push"); break;
        case Feature.analytics: strings.add("analytics"); break;
        case Feature.inAppAutomation: strings.add("in_app_automation"); break;
        case Feature.tagsAndAttributes: strings.add("tags_and_attributes"); break;
        case Feature.messageCenter: strings.add("message_center"); break;
        case Feature.contacts: strings.add("contacts"); break;
      }
    });
    return strings;
  }

  static ChannelScope parseChannelScope(String scope) {
    switch (scope) {
      case "app": return ChannelScope.app;
      case "web": return ChannelScope.web;
      case "email": return ChannelScope.email;
      case "sms": return ChannelScope.sms;
      default: throw new ArgumentError("Invalid scope: $scope");
    }
  }

  static String toChannelScopeString(ChannelScope scope) {
    switch (scope) {
      case ChannelScope.app: return "app";
      case ChannelScope.web: return "web";
      case ChannelScope.email: return "email";
      case ChannelScope.sms: return "sms";
      default: throw new ArgumentError("Invalid scope: ${scope.name}");
    }
  }
}