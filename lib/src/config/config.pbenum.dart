///
//  Generated code. Do not modify.
//  source: config.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields

// ignore_for_file: UNDEFINED_SHOWN_NAME
import 'dart:core' as $core;
import 'package:protobuf/protobuf.dart' as $pb;

class LogLevel extends $pb.ProtobufEnum {
  static const LogLevel NONE = LogLevel._(
      0,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'NONE');
  static const LogLevel VERBOSE = LogLevel._(
      8,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'VERBOSE');
  static const LogLevel DEBUG = LogLevel._(
      3,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'DEBUG');
  static const LogLevel INFO = LogLevel._(
      4,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'INFO');
  static const LogLevel WARN = LogLevel._(
      5,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'WARN');
  static const LogLevel ERROR = LogLevel._(
      6,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'ERROR');

  static const $core.List<LogLevel> values = <LogLevel>[
    NONE,
    VERBOSE,
    DEBUG,
    INFO,
    WARN,
    ERROR,
  ];

  static final $core.Map<$core.int, LogLevel> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static LogLevel? valueOf($core.int value) => _byValue[value];

  const LogLevel._($core.int v, $core.String n) : super(v, n);
}

class Site extends $pb.ProtobufEnum {
  static const Site SITE_US = Site._(
      0,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'SITE_US');
  static const Site SITE_EU = Site._(
      1,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'SITE_EU');

  static const $core.List<Site> values = <Site>[
    SITE_US,
    SITE_EU,
  ];

  static final $core.Map<$core.int, Site> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static Site? valueOf($core.int value) => _byValue[value];

  const Site._($core.int v, $core.String n) : super(v, n);
}

class Feature extends $pb.ProtobufEnum {
  static const Feature ENABLE_ALL = Feature._(
      0,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'ENABLE_ALL');
  static const Feature ENABLE_NONE = Feature._(
      1,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'ENABLE_NONE');
  static const Feature ENABLE_IN_APP_AUTOMATION = Feature._(
      2,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'ENABLE_IN_APP_AUTOMATION');
  static const Feature ENABLE_MESSAGE_CENTER = Feature._(
      3,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'ENABLE_MESSAGE_CENTER');
  static const Feature ENABLE_PUSH = Feature._(
      4,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'ENABLE_PUSH');
  static const Feature ENABLE_CHAT = Feature._(
      5,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'ENABLE_CHAT');
  static const Feature ENABLE_ANALYTICS = Feature._(
      6,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'ENABLE_ANALYTICS');
  static const Feature ENABLE_TAGS_AND_ATTRIBUTES = Feature._(
      7,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'ENABLE_TAGS_AND_ATTRIBUTES');
  static const Feature ENABLE_CONTACTS = Feature._(
      8,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'ENABLE_CONTACTS');
  static const Feature ENABLE_LOCATION = Feature._(
      9,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'ENABLE_LOCATION');

  static const $core.List<Feature> values = <Feature>[
    ENABLE_ALL,
    ENABLE_NONE,
    ENABLE_IN_APP_AUTOMATION,
    ENABLE_MESSAGE_CENTER,
    ENABLE_PUSH,
    ENABLE_CHAT,
    ENABLE_ANALYTICS,
    ENABLE_TAGS_AND_ATTRIBUTES,
    ENABLE_CONTACTS,
    ENABLE_LOCATION,
  ];

  static final $core.Map<$core.int, Feature> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static Feature? valueOf($core.int value) => _byValue[value];

  const Feature._($core.int v, $core.String n) : super(v, n);
}
