import "feature.dart";

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
        default: print("Invalid feature");
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
}