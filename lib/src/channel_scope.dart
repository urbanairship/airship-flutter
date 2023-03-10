/// Channel Scope types.
enum ChannelScope { app, web, email, sms }

extension ParseToString on ChannelScope {
  String getStringValue() {
    return this.toString().split('.').last;
  }
}
