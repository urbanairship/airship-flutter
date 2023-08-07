enum Feature {
  push,
  analytics,
  in_app_automation,
  tags_and_attributes,
  chat,
  location,
  message_center,
  contacts;

  static Feature fromString(String feature) {
    var f = Feature.values.asNameMap()[feature];
    if (f == null) {
      throw new ArgumentError('Invalid feature: $feature');
    }
    return f;
  }
}