class AirshipChannel {

  const MethodChannel _channel;

  const AirshipChannel._internal(this._channel)

  /// Gets the channel ID.
  Future<String?> get channelId async {
    return await _channel.invokeMethod('channel#getChannelId');
  }
}