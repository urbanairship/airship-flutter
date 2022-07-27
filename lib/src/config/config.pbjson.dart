///
//  Generated code. Do not modify.
//  source: config.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields,deprecated_member_use_from_same_package

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use logLevelDescriptor instead')
const LogLevel$json = const {
  '1': 'LogLevel',
  '2': const [
    const {'1': 'NONE', '2': 0},
    const {'1': 'VERBOSE', '2': 8},
    const {'1': 'DEBUG', '2': 3},
    const {'1': 'INFO', '2': 4},
    const {'1': 'WARN', '2': 5},
    const {'1': 'ERROR', '2': 6},
  ],
};

/// Descriptor for `LogLevel`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List logLevelDescriptor = $convert.base64Decode(
    'CghMb2dMZXZlbBIICgROT05FEAASCwoHVkVSQk9TRRAIEgkKBURFQlVHEAMSCAoESU5GTxAEEggKBFdBUk4QBRIJCgVFUlJPUhAG');
@$core.Deprecated('Use siteDescriptor instead')
const Site$json = const {
  '1': 'Site',
  '2': const [
    const {'1': 'SITE_US', '2': 0},
    const {'1': 'SITE_EU', '2': 1},
  ],
};

/// Descriptor for `Site`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List siteDescriptor =
    $convert.base64Decode('CgRTaXRlEgsKB1NJVEVfVVMQABILCgdTSVRFX0VVEAE=');
@$core.Deprecated('Use featureDescriptor instead')
const Feature$json = const {
  '1': 'Feature',
  '2': const [
    const {'1': 'ENABLE_ALL', '2': 0},
    const {'1': 'ENABLE_IN_APP_AUTOMATION', '2': 2},
    const {'1': 'ENABLE_MESSAGE_CENTER', '2': 3},
    const {'1': 'ENABLE_PUSH', '2': 4},
    const {'1': 'ENABLE_CHAT', '2': 5},
    const {'1': 'ENABLE_ANALYTICS', '2': 6},
    const {'1': 'ENABLE_TAGS_AND_ATTRIBUTES', '2': 7},
    const {'1': 'ENABLE_CONTACTS', '2': 8},
    const {'1': 'ENABLE_LOCATION', '2': 9},
    const {'1': 'ENABLE_NONE', '2': 1},
  ],
};

/// Descriptor for `Feature`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List featureDescriptor = $convert.base64Decode(
    'CgdGZWF0dXJlEg4KCkVOQUJMRV9BTEwQABIcChhFTkFCTEVfSU5fQVBQX0FVVE9NQVRJT04QAhIZChVFTkFCTEVfTUVTU0FHRV9DRU5URVIQAxIPCgtFTkFCTEVfUFVTSBAEEg8KC0VOQUJMRV9DSEFUEAUSFAoQRU5BQkxFX0FOQUxZVElDUxAGEh4KGkVOQUJMRV9UQUdTX0FORF9BVFRSSUJVVEVTEAcSEwoPRU5BQkxFX0NPTlRBQ1RTEAgSEwoPRU5BQkxFX0xPQ0FUSU9OEAkSDwoLRU5BQkxFX05PTkUQAQ==');
@$core.Deprecated('Use airshipEnvDescriptor instead')
const AirshipEnv$json = const {
  '1': 'AirshipEnv',
  '2': const [
    const {'1': 'app_key', '3': 1, '4': 1, '5': 9, '10': 'appKey'},
    const {'1': 'app_secret', '3': 2, '4': 1, '5': 9, '10': 'appSecret'},
    const {
      '1': 'log_level',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.LogLevel',
      '10': 'logLevel'
    },
  ],
};

/// Descriptor for `AirshipEnv`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List airshipEnvDescriptor = $convert.base64Decode(
    'CgpBaXJzaGlwRW52EhcKB2FwcF9rZXkYASABKAlSBmFwcEtleRIdCgphcHBfc2VjcmV0GAIgASgJUglhcHBTZWNyZXQSJgoJbG9nX2xldmVsGAMgASgOMgkuTG9nTGV2ZWxSCGxvZ0xldmVs');
@$core.Deprecated('Use androidNotificationConfigDescriptor instead')
const AndroidNotificationConfig$json = const {
  '1': 'AndroidNotificationConfig',
  '2': const [
    const {'1': 'icon', '3': 1, '4': 1, '5': 9, '10': 'icon'},
    const {'1': 'large_icon', '3': 2, '4': 1, '5': 9, '10': 'largeIcon'},
    const {'1': 'accent_color', '3': 3, '4': 1, '5': 9, '10': 'accentColor'},
    const {
      '1': 'default_channel_id',
      '3': 4,
      '4': 1,
      '5': 9,
      '10': 'defaultChannelId'
    },
  ],
};

/// Descriptor for `AndroidNotificationConfig`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List androidNotificationConfigDescriptor =
    $convert.base64Decode(
        'ChlBbmRyb2lkTm90aWZpY2F0aW9uQ29uZmlnEhIKBGljb24YASABKAlSBGljb24SHQoKbGFyZ2VfaWNvbhgCIAEoCVIJbGFyZ2VJY29uEiEKDGFjY2VudF9jb2xvchgDIAEoCVILYWNjZW50Q29sb3ISLAoSZGVmYXVsdF9jaGFubmVsX2lkGAQgASgJUhBkZWZhdWx0Q2hhbm5lbElk');
@$core.Deprecated('Use androidConfigDescriptor instead')
const AndroidConfig$json = const {
  '1': 'AndroidConfig',
  '2': const [
    const {'1': 'app_store_uri', '3': 1, '4': 1, '5': 9, '10': 'appStoreUri'},
    const {
      '1': 'fcm_firebase_app_name',
      '3': 2,
      '4': 1,
      '5': 9,
      '10': 'fcmFirebaseAppName'
    },
    const {
      '1': 'notification',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.AndroidNotificationConfig',
      '10': 'notification'
    },
  ],
};

/// Descriptor for `AndroidConfig`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List androidConfigDescriptor = $convert.base64Decode(
    'Cg1BbmRyb2lkQ29uZmlnEiIKDWFwcF9zdG9yZV91cmkYASABKAlSC2FwcFN0b3JlVXJpEjEKFWZjbV9maXJlYmFzZV9hcHBfbmFtZRgCIAEoCVISZmNtRmlyZWJhc2VBcHBOYW1lEj4KDG5vdGlmaWNhdGlvbhgDIAEoCzIaLkFuZHJvaWROb3RpZmljYXRpb25Db25maWdSDG5vdGlmaWNhdGlvbg==');
@$core.Deprecated('Use iosConfigDescriptor instead')
const IosConfig$json = const {
  '1': 'IosConfig',
  '2': const [
    const {'1': 'itunes_id', '3': 1, '4': 1, '5': 9, '10': 'itunesId'},
  ],
};

/// Descriptor for `IosConfig`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List iosConfigDescriptor = $convert
    .base64Decode('CglJb3NDb25maWcSGwoJaXR1bmVzX2lkGAEgASgJUghpdHVuZXNJZA==');
@$core.Deprecated('Use airshipConfigDescriptor instead')
const AirshipConfig$json = const {
  '1': 'AirshipConfig',
  '2': const [
    const {
      '1': 'production',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.AirshipEnv',
      '10': 'production'
    },
    const {
      '1': 'development',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.AirshipEnv',
      '10': 'development'
    },
    const {
      '1': 'default_env',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.AirshipEnv',
      '10': 'defaultEnv'
    },
    const {
      '1': 'android',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.AndroidConfig',
      '10': 'android'
    },
    const {'1': 'in_production', '3': 4, '4': 1, '5': 8, '10': 'inProduction'},
    const {'1': 'site', '3': 5, '4': 1, '5': 14, '6': '.Site', '10': 'site'},
    const {'1': 'url_allow_list', '3': 6, '4': 3, '5': 9, '10': 'urlAllowList'},
    const {
      '1': 'url_allow_list_scope_open_url',
      '3': 7,
      '4': 3,
      '5': 9,
      '10': 'urlAllowListScopeOpenUrl'
    },
    const {
      '1': 'url_allowlist_scope_javascript_interface',
      '3': 8,
      '4': 3,
      '5': 9,
      '10': 'urlAllowlistScopeJavascriptInterface'
    },
    const {
      '1': 'is_channel_creation_delay_enabled',
      '3': 9,
      '4': 1,
      '5': 8,
      '10': 'isChannelCreationDelayEnabled'
    },
    const {
      '1': 'require_initial_remote_config_enabled',
      '3': 10,
      '4': 1,
      '5': 8,
      '10': 'requireInitialRemoteConfigEnabled'
    },
    const {
      '1': 'features_enabled',
      '3': 11,
      '4': 3,
      '5': 14,
      '6': '.Feature',
      '10': 'featuresEnabled'
    },
    const {
      '1': 'ios',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.IosConfig',
      '10': 'ios'
    },
  ],
};

/// Descriptor for `AirshipConfig`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List airshipConfigDescriptor = $convert.base64Decode(
    'Cg1BaXJzaGlwQ29uZmlnEisKCnByb2R1Y3Rpb24YASABKAsyCy5BaXJzaGlwRW52Ugpwcm9kdWN0aW9uEi0KC2RldmVsb3BtZW50GAIgASgLMgsuQWlyc2hpcEVudlILZGV2ZWxvcG1lbnQSLAoLZGVmYXVsdF9lbnYYDSABKAsyCy5BaXJzaGlwRW52UgpkZWZhdWx0RW52EigKB2FuZHJvaWQYAyABKAsyDi5BbmRyb2lkQ29uZmlnUgdhbmRyb2lkEiMKDWluX3Byb2R1Y3Rpb24YBCABKAhSDGluUHJvZHVjdGlvbhIZCgRzaXRlGAUgASgOMgUuU2l0ZVIEc2l0ZRIkCg51cmxfYWxsb3dfbGlzdBgGIAMoCVIMdXJsQWxsb3dMaXN0Ej8KHXVybF9hbGxvd19saXN0X3Njb3BlX29wZW5fdXJsGAcgAygJUhh1cmxBbGxvd0xpc3RTY29wZU9wZW5VcmwSVgoodXJsX2FsbG93bGlzdF9zY29wZV9qYXZhc2NyaXB0X2ludGVyZmFjZRgIIAMoCVIkdXJsQWxsb3dsaXN0U2NvcGVKYXZhc2NyaXB0SW50ZXJmYWNlEkgKIWlzX2NoYW5uZWxfY3JlYXRpb25fZGVsYXlfZW5hYmxlZBgJIAEoCFIdaXNDaGFubmVsQ3JlYXRpb25EZWxheUVuYWJsZWQSUAolcmVxdWlyZV9pbml0aWFsX3JlbW90ZV9jb25maWdfZW5hYmxlZBgKIAEoCFIhcmVxdWlyZUluaXRpYWxSZW1vdGVDb25maWdFbmFibGVkEjMKEGZlYXR1cmVzX2VuYWJsZWQYCyADKA4yCC5GZWF0dXJlUg9mZWF0dXJlc0VuYWJsZWQSHAoDaW9zGAwgASgLMgouSW9zQ29uZmlnUgNpb3M=');
