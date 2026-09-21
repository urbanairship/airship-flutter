# Flutter 13.x Changelog

[Migration Guide](https://github.com/urbanairship/airship-flutter/blob/main/MIGRATION.md)
[All Releases](https://github.com/urbanairship/airship-flutter/releases)

## Version 13.0.0 - September 21, 2026

Major release that updates the Android SDK to 21.0.2 and iOS SDK to 21.0.2; drops CocoaPods support on iOS in favor of Swift Package Manager; raises Android's minimum SDK to 26; and adds feature flag status and `waitRefresh` APIs. The Dart plugin API itself has no breaking changes — existing `Airship.*` calls are unaffected. See `MIGRATION.md` for upgrade steps.

### Changes
- **Potentially breaking:** Native Android SDK 21 and iOS SDK 21 are major version bumps with their own breaking changes. If your app also integrates the native Airship SDK directly (not just through this plugin), review the [Android SDK migration guide](https://github.com/urbanairship/android-library/blob/main/documentation/migration/migration-guide-20-21.md) and [iOS SDK migration guide](https://github.com/urbanairship/ios-library/blob/main/Documentation/Migration/migration-guide-20-21.md) before upgrading.
- **Breaking:** iOS no longer supports CocoaPods. The plugin is distributed via Swift Package Manager only, matching the native iOS SDK 21. Apps must have SPM enabled (`flutter config --enable-swift-package-manager` on Flutter versions where it isn't the default).
- **Breaking:** Raised Android's `minSdkVersion` to 26, matching the native Android SDK 21 requirement.
- **Breaking:** Raised the minimum Flutter version to 3.44.0 (and the Dart SDK floor to 3.10.0, which ships with it), the first stable release with Swift Package Manager enabled by default. Earlier versions can only resolve this plugin after `flutter config --enable-swift-package-manager`, and fail `flutter pub get` on every platform without it.
- The example app now adopts the UIScene lifecycle, which iOS 27 requires of apps built against its SDK.
- Fixed the embedded view falling back to no height when no window reported as key, which could collapse a self-sizing `AirshipEmbeddedView`.
- Updated Android SDK to [21.0.2](https://github.com/urbanairship/android-library/releases/tag/21.0.2)
- Updated iOS SDK to [21.0.2](https://github.com/urbanairship/ios-library/releases/tag/21.0.2)
- Added `featureFlagManager.status()` to get the on-device status of the feature flag listing (`upToDate`, `stale`, or `outOfDate`).
- Added `featureFlagManager.statusUpdates`, a stream of `FeatureFlagStatusChangedEvent`s fired when the feature flag status changes.
- Added `featureFlagManager.waitRefresh()` to suspend until the feature flag listing refreshes, or an optional `maxTime` elapses.
