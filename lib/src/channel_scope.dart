/// Channel Scope types.
enum ChannelScope { app, web, email, sms }

extension ChannelScopeToString on ChannelScope {
  String getStringValue() {
    return this.toString().split('.').last;
  }
}

extension ChannelScopeString on String {
  ChannelScope get channelScope {
    switch (this) {
      case 'app':
        return ChannelScope.app;
      case 'web':
        return ChannelScope.web;
      case 'email':
        return ChannelScope.email;
      case 'sms':
        return ChannelScope.sms;
      default:
        return ChannelScope.app;
    }
  }
}