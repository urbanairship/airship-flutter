import "feature.dart";
import "ios_push_options.dart";

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
        default: print("Invalid feature $element");
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

  static List<IOSAuthorizedNotificationSetting> parseIOSAuthorizedSettings(List<String> strings) {
    var settings = <IOSAuthorizedNotificationSetting>[];
    strings.forEach((element) {
      switch (element) {
        case "alert":
          settings.add(IOSAuthorizedNotificationSetting.alert);
          break;
        case "sound":
          settings.add(IOSAuthorizedNotificationSetting.sound);
          break;
        case "badge":
          settings.add(IOSAuthorizedNotificationSetting.badge);
          break;
        case "lock_screen":
          settings.add(IOSAuthorizedNotificationSetting.lockScreen);
          break;
        case "car_play":
          settings.add(IOSAuthorizedNotificationSetting.carPlay);
          break;
        case "notification_center":
          settings.add(IOSAuthorizedNotificationSetting.notificationCenter);
          break;
        case "notification_center":
          settings.add(IOSAuthorizedNotificationSetting.notificationCenter);
          break;
        case "critical_alert":
          settings.add(IOSAuthorizedNotificationSetting.criticalAlert);
          break;
        case "announcement":
          settings.add(IOSAuthorizedNotificationSetting.announcement);
          break;
        case "scheduled_delivery":
          settings.add(IOSAuthorizedNotificationSetting.scheduledDelivery);
          break;
        case "time_sensitive":
          settings.add(IOSAuthorizedNotificationSetting.timeSensitive);
          break;
        default:
          print("Invalid setting: $element");
          break;
      }
    });

    return settings;
  }

  static IOSAuthorizedNotificationStatus parseIOSAuthorizedStatus(String status) {
    switch (status) {
      case "not_determined":
        return IOSAuthorizedNotificationStatus.notDetermined;
      case "denied":
        return IOSAuthorizedNotificationStatus.denied;
      case "authorized":
        return IOSAuthorizedNotificationStatus.authorized;
      case "provisional":
        return IOSAuthorizedNotificationStatus.provisional;
      case "ephemeral":
        return IOSAuthorizedNotificationStatus.ephemeral;
      default:
        print("Invalid status: $status");
        return IOSAuthorizedNotificationStatus.notDetermined;
    }
  }
}