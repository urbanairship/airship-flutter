import 'airship_module.dart';


class AirshipLocale {

  final AirshipModule _module;

  AirshipLocale(AirshipModule module) : _module = module;

  /// Sets the locale override
  Future<void> setLocaleOverride(String localeIdentifier) async {
    return await _module.channel.invokeMethod('locale#setLocaleOverride', localeIdentifier);
  }

  /// Clears the locale override.
  Future<void> clearLocaleOverride() async {
    return await _module.channel.invokeMethod('locale#clearLocaleOverride');
  }

  /// Gets the current locale.
  Future<String> get locale async {
    return await _module.channel.invokeMethod('locale#getCurrentLocale');
  }

}