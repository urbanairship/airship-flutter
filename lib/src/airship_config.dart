class AirshipConfig {

  final ConfigEnvironment? defaultEnvironment;

  AirshipConfig(this.defaultEnvironment);

  Map<String, dynamic> toJson() {
    return {
      "default": defaultEnvironment?._toJson()
    };
  }
}

class ConfigEnvironment {

  final String appKey;
  final String appSecret;

  ConfigEnvironment(this.appKey, this.appSecret);

  Map<String, dynamic> _toJson() {
    return {
      "appKey": appKey,
      "appSecret": appSecret
    };
  }
}
