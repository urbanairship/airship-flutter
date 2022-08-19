///
//  Generated code. Do not modify.
//  source: config.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'config.pbenum.dart';

export 'config.pbenum.dart';

class AirshipEnv extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'AirshipEnv',
      createEmptyInstance: create)
    ..aOS(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'appKey')
    ..aOS(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'appSecret')
    ..e<LogLevel>(
        3,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'logLevel',
        $pb.PbFieldType.OE,
        defaultOrMaker: LogLevel.NONE,
        valueOf: LogLevel.valueOf,
        enumValues: LogLevel.values)
    ..hasRequiredFields = false;

  AirshipEnv._() : super();
  factory AirshipEnv({
    $core.String? appKey,
    $core.String? appSecret,
    LogLevel? logLevel,
  }) {
    final _result = create();
    if (appKey != null) {
      _result.appKey = appKey;
    }
    if (appSecret != null) {
      _result.appSecret = appSecret;
    }
    if (logLevel != null) {
      _result.logLevel = logLevel;
    }
    return _result;
  }
  factory AirshipEnv.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory AirshipEnv.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  AirshipEnv clone() => AirshipEnv()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  AirshipEnv copyWith(void Function(AirshipEnv) updates) =>
      super.copyWith((message) => updates(message as AirshipEnv))
          as AirshipEnv; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static AirshipEnv create() => AirshipEnv._();
  AirshipEnv createEmptyInstance() => create();
  static $pb.PbList<AirshipEnv> createRepeated() => $pb.PbList<AirshipEnv>();
  @$core.pragma('dart2js:noInline')
  static AirshipEnv getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AirshipEnv>(create);
  static AirshipEnv? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get appKey => $_getSZ(0);
  @$pb.TagNumber(1)
  set appKey($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasAppKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearAppKey() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get appSecret => $_getSZ(1);
  @$pb.TagNumber(2)
  set appSecret($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasAppSecret() => $_has(1);
  @$pb.TagNumber(2)
  void clearAppSecret() => clearField(2);

  @$pb.TagNumber(3)
  LogLevel get logLevel => $_getN(2);
  @$pb.TagNumber(3)
  set logLevel(LogLevel v) {
    setField(3, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasLogLevel() => $_has(2);
  @$pb.TagNumber(3)
  void clearLogLevel() => clearField(3);
}

class AndroidNotificationConfig extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'AndroidNotificationConfig',
      createEmptyInstance: create)
    ..aOS(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'icon')
    ..aOS(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'largeIcon')
    ..aOS(
        3,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'accentColor')
    ..aOS(
        4,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'defaultChannelId')
    ..hasRequiredFields = false;

  AndroidNotificationConfig._() : super();
  factory AndroidNotificationConfig({
    $core.String? icon,
    $core.String? largeIcon,
    $core.String? accentColor,
    $core.String? defaultChannelId,
  }) {
    final _result = create();
    if (icon != null) {
      _result.icon = icon;
    }
    if (largeIcon != null) {
      _result.largeIcon = largeIcon;
    }
    if (accentColor != null) {
      _result.accentColor = accentColor;
    }
    if (defaultChannelId != null) {
      _result.defaultChannelId = defaultChannelId;
    }
    return _result;
  }
  factory AndroidNotificationConfig.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory AndroidNotificationConfig.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  AndroidNotificationConfig clone() =>
      AndroidNotificationConfig()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  AndroidNotificationConfig copyWith(
          void Function(AndroidNotificationConfig) updates) =>
      super.copyWith((message) => updates(message as AndroidNotificationConfig))
          as AndroidNotificationConfig; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static AndroidNotificationConfig create() => AndroidNotificationConfig._();
  AndroidNotificationConfig createEmptyInstance() => create();
  static $pb.PbList<AndroidNotificationConfig> createRepeated() =>
      $pb.PbList<AndroidNotificationConfig>();
  @$core.pragma('dart2js:noInline')
  static AndroidNotificationConfig getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AndroidNotificationConfig>(create);
  static AndroidNotificationConfig? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get icon => $_getSZ(0);
  @$pb.TagNumber(1)
  set icon($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasIcon() => $_has(0);
  @$pb.TagNumber(1)
  void clearIcon() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get largeIcon => $_getSZ(1);
  @$pb.TagNumber(2)
  set largeIcon($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasLargeIcon() => $_has(1);
  @$pb.TagNumber(2)
  void clearLargeIcon() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get accentColor => $_getSZ(2);
  @$pb.TagNumber(3)
  set accentColor($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasAccentColor() => $_has(2);
  @$pb.TagNumber(3)
  void clearAccentColor() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get defaultChannelId => $_getSZ(3);
  @$pb.TagNumber(4)
  set defaultChannelId($core.String v) {
    $_setString(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasDefaultChannelId() => $_has(3);
  @$pb.TagNumber(4)
  void clearDefaultChannelId() => clearField(4);
}

class AndroidConfig extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'AndroidConfig',
      createEmptyInstance: create)
    ..aOS(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'appStoreUri')
    ..aOS(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'fcmFirebaseAppName')
    ..aOM<AndroidNotificationConfig>(
        3,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'notification',
        subBuilder: AndroidNotificationConfig.create)
    ..hasRequiredFields = false;

  AndroidConfig._() : super();
  factory AndroidConfig({
    $core.String? appStoreUri,
    $core.String? fcmFirebaseAppName,
    AndroidNotificationConfig? notification,
  }) {
    final _result = create();
    if (appStoreUri != null) {
      _result.appStoreUri = appStoreUri;
    }
    if (fcmFirebaseAppName != null) {
      _result.fcmFirebaseAppName = fcmFirebaseAppName;
    }
    if (notification != null) {
      _result.notification = notification;
    }
    return _result;
  }
  factory AndroidConfig.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory AndroidConfig.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  AndroidConfig clone() => AndroidConfig()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  AndroidConfig copyWith(void Function(AndroidConfig) updates) =>
      super.copyWith((message) => updates(message as AndroidConfig))
          as AndroidConfig; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static AndroidConfig create() => AndroidConfig._();
  AndroidConfig createEmptyInstance() => create();
  static $pb.PbList<AndroidConfig> createRepeated() =>
      $pb.PbList<AndroidConfig>();
  @$core.pragma('dart2js:noInline')
  static AndroidConfig getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AndroidConfig>(create);
  static AndroidConfig? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get appStoreUri => $_getSZ(0);
  @$pb.TagNumber(1)
  set appStoreUri($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasAppStoreUri() => $_has(0);
  @$pb.TagNumber(1)
  void clearAppStoreUri() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get fcmFirebaseAppName => $_getSZ(1);
  @$pb.TagNumber(2)
  set fcmFirebaseAppName($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasFcmFirebaseAppName() => $_has(1);
  @$pb.TagNumber(2)
  void clearFcmFirebaseAppName() => clearField(2);

  @$pb.TagNumber(3)
  AndroidNotificationConfig get notification => $_getN(2);
  @$pb.TagNumber(3)
  set notification(AndroidNotificationConfig v) {
    setField(3, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasNotification() => $_has(2);
  @$pb.TagNumber(3)
  void clearNotification() => clearField(3);
  @$pb.TagNumber(3)
  AndroidNotificationConfig ensureNotification() => $_ensure(2);
}

class IosConfig extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'IosConfig',
      createEmptyInstance: create)
    ..aOS(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'itunesId')
    ..hasRequiredFields = false;

  IosConfig._() : super();
  factory IosConfig({
    $core.String? itunesId,
  }) {
    final _result = create();
    if (itunesId != null) {
      _result.itunesId = itunesId;
    }
    return _result;
  }
  factory IosConfig.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory IosConfig.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  IosConfig clone() => IosConfig()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  IosConfig copyWith(void Function(IosConfig) updates) =>
      super.copyWith((message) => updates(message as IosConfig))
          as IosConfig; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static IosConfig create() => IosConfig._();
  IosConfig createEmptyInstance() => create();
  static $pb.PbList<IosConfig> createRepeated() => $pb.PbList<IosConfig>();
  @$core.pragma('dart2js:noInline')
  static IosConfig getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<IosConfig>(create);
  static IosConfig? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get itunesId => $_getSZ(0);
  @$pb.TagNumber(1)
  set itunesId($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasItunesId() => $_has(0);
  @$pb.TagNumber(1)
  void clearItunesId() => clearField(1);
}

class AirshipConfig extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'AirshipConfig',
      createEmptyInstance: create)
    ..aOM<AirshipEnv>(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'production',
        subBuilder: AirshipEnv.create)
    ..aOM<AirshipEnv>(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'development',
        subBuilder: AirshipEnv.create)
    ..aOM<AndroidConfig>(
        3,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'android',
        subBuilder: AndroidConfig.create)
    ..aOB(
        4,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'inProduction')
    ..e<Site>(
        5,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'site',
        $pb.PbFieldType.OE,
        defaultOrMaker: Site.SITE_US,
        valueOf: Site.valueOf,
        enumValues: Site.values)
    ..pPS(
        6,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'urlAllowList')
    ..pPS(
        7,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'urlAllowListScopeOpenUrl')
    ..pPS(
        8,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'urlAllowlistScopeJavascriptInterface')
    ..aOB(
        9,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'isChannelCreationDelayEnabled')
    ..aOB(
        10,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'requireInitialRemoteConfigEnabled')
    ..pc<Feature>(
        11,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'featuresEnabled',
        $pb.PbFieldType.PE,
        valueOf: Feature.valueOf,
        enumValues: Feature.values)
    ..aOM<IosConfig>(
        12,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'ios',
        subBuilder: IosConfig.create)
    ..aOM<AirshipEnv>(
        13,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'defaultEnv',
        subBuilder: AirshipEnv.create)
    ..hasRequiredFields = false;

  AirshipConfig._() : super();
  factory AirshipConfig({
    AirshipEnv? production,
    AirshipEnv? development,
    AndroidConfig? android,
    $core.bool? inProduction,
    Site? site,
    $core.Iterable<$core.String>? urlAllowList,
    $core.Iterable<$core.String>? urlAllowListScopeOpenUrl,
    $core.Iterable<$core.String>? urlAllowlistScopeJavascriptInterface,
    $core.bool? isChannelCreationDelayEnabled,
    $core.bool? requireInitialRemoteConfigEnabled,
    $core.Iterable<Feature>? featuresEnabled,
    IosConfig? ios,
    AirshipEnv? defaultEnv,
  }) {
    final _result = create();
    if (production != null) {
      _result.production = production;
    }
    if (development != null) {
      _result.development = development;
    }
    if (android != null) {
      _result.android = android;
    }
    if (inProduction != null) {
      _result.inProduction = inProduction;
    }
    if (site != null) {
      _result.site = site;
    }
    if (urlAllowList != null) {
      _result.urlAllowList.addAll(urlAllowList);
    }
    if (urlAllowListScopeOpenUrl != null) {
      _result.urlAllowListScopeOpenUrl.addAll(urlAllowListScopeOpenUrl);
    }
    if (urlAllowlistScopeJavascriptInterface != null) {
      _result.urlAllowlistScopeJavascriptInterface
          .addAll(urlAllowlistScopeJavascriptInterface);
    }
    if (isChannelCreationDelayEnabled != null) {
      _result.isChannelCreationDelayEnabled = isChannelCreationDelayEnabled;
    }
    if (requireInitialRemoteConfigEnabled != null) {
      _result.requireInitialRemoteConfigEnabled =
          requireInitialRemoteConfigEnabled;
    }
    if (featuresEnabled != null) {
      _result.featuresEnabled.addAll(featuresEnabled);
    }
    if (ios != null) {
      _result.ios = ios;
    }
    if (defaultEnv != null) {
      _result.defaultEnv = defaultEnv;
    }
    return _result;
  }
  factory AirshipConfig.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory AirshipConfig.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  AirshipConfig clone() => AirshipConfig()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  AirshipConfig copyWith(void Function(AirshipConfig) updates) =>
      super.copyWith((message) => updates(message as AirshipConfig))
          as AirshipConfig; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static AirshipConfig create() => AirshipConfig._();
  AirshipConfig createEmptyInstance() => create();
  static $pb.PbList<AirshipConfig> createRepeated() =>
      $pb.PbList<AirshipConfig>();
  @$core.pragma('dart2js:noInline')
  static AirshipConfig getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AirshipConfig>(create);
  static AirshipConfig? _defaultInstance;

  @$pb.TagNumber(1)
  AirshipEnv get production => $_getN(0);
  @$pb.TagNumber(1)
  set production(AirshipEnv v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasProduction() => $_has(0);
  @$pb.TagNumber(1)
  void clearProduction() => clearField(1);
  @$pb.TagNumber(1)
  AirshipEnv ensureProduction() => $_ensure(0);

  @$pb.TagNumber(2)
  AirshipEnv get development => $_getN(1);
  @$pb.TagNumber(2)
  set development(AirshipEnv v) {
    setField(2, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasDevelopment() => $_has(1);
  @$pb.TagNumber(2)
  void clearDevelopment() => clearField(2);
  @$pb.TagNumber(2)
  AirshipEnv ensureDevelopment() => $_ensure(1);

  @$pb.TagNumber(3)
  AndroidConfig get android => $_getN(2);
  @$pb.TagNumber(3)
  set android(AndroidConfig v) {
    setField(3, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasAndroid() => $_has(2);
  @$pb.TagNumber(3)
  void clearAndroid() => clearField(3);
  @$pb.TagNumber(3)
  AndroidConfig ensureAndroid() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.bool get inProduction => $_getBF(3);
  @$pb.TagNumber(4)
  set inProduction($core.bool v) {
    $_setBool(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasInProduction() => $_has(3);
  @$pb.TagNumber(4)
  void clearInProduction() => clearField(4);

  @$pb.TagNumber(5)
  Site get site => $_getN(4);
  @$pb.TagNumber(5)
  set site(Site v) {
    setField(5, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasSite() => $_has(4);
  @$pb.TagNumber(5)
  void clearSite() => clearField(5);

  @$pb.TagNumber(6)
  $core.List<$core.String> get urlAllowList => $_getList(5);

  @$pb.TagNumber(7)
  $core.List<$core.String> get urlAllowListScopeOpenUrl => $_getList(6);

  @$pb.TagNumber(8)
  $core.List<$core.String> get urlAllowlistScopeJavascriptInterface =>
      $_getList(7);

  @$pb.TagNumber(9)
  $core.bool get isChannelCreationDelayEnabled => $_getBF(8);
  @$pb.TagNumber(9)
  set isChannelCreationDelayEnabled($core.bool v) {
    $_setBool(8, v);
  }

  @$pb.TagNumber(9)
  $core.bool hasIsChannelCreationDelayEnabled() => $_has(8);
  @$pb.TagNumber(9)
  void clearIsChannelCreationDelayEnabled() => clearField(9);

  @$pb.TagNumber(10)
  $core.bool get requireInitialRemoteConfigEnabled => $_getBF(9);
  @$pb.TagNumber(10)
  set requireInitialRemoteConfigEnabled($core.bool v) {
    $_setBool(9, v);
  }

  @$pb.TagNumber(10)
  $core.bool hasRequireInitialRemoteConfigEnabled() => $_has(9);
  @$pb.TagNumber(10)
  void clearRequireInitialRemoteConfigEnabled() => clearField(10);

  @$pb.TagNumber(11)
  $core.List<Feature> get featuresEnabled => $_getList(10);

  @$pb.TagNumber(12)
  IosConfig get ios => $_getN(11);
  @$pb.TagNumber(12)
  set ios(IosConfig v) {
    setField(12, v);
  }

  @$pb.TagNumber(12)
  $core.bool hasIos() => $_has(11);
  @$pb.TagNumber(12)
  void clearIos() => clearField(12);
  @$pb.TagNumber(12)
  IosConfig ensureIos() => $_ensure(11);

  @$pb.TagNumber(13)
  AirshipEnv get defaultEnv => $_getN(12);
  @$pb.TagNumber(13)
  set defaultEnv(AirshipEnv v) {
    setField(13, v);
  }

  @$pb.TagNumber(13)
  $core.bool hasDefaultEnv() => $_has(12);
  @$pb.TagNumber(13)
  void clearDefaultEnv() => clearField(13);
  @$pb.TagNumber(13)
  AirshipEnv ensureDefaultEnv() => $_ensure(12);
}
