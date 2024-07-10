# Flutter Plugin Changelog

## Version 7.6.0 - July 10, 2024
Minor release that updates the Android SDK to 18.1.1 and the iOS SDK to 18.5.0.

### Changes
- Updated Android SDK to 18.1.1
- Updated iOS SDK to 18.5.0
- Updated airship-mobile-framework-proxy to 7.0.0
- Updated Kotlin version to 1.9.0
- Added support for configuring log privacy level on iOS

## Version 7.5.0 - June 20, 2024
Minor release that updates iOS SDK to 18.4.1, updates Android compileSDKVersion from 33 to 34, sets Android source and target compatibility to Java 17, updates android example build configuration, improves example UI, and updates the airship mobile framework proxy to 6.3.1 which includes a fix for event management.

### Changes
- Updated iOS SDK to 18.4.1
- Updated airship-mobile-framework-proxy to 6.3.1
- Fixed Event Emitter bug
- Updated Android compileSDKVersion from 33 to 34 and set source and target compatibility to Java 17
- Updated Android example build configuration
- Improved example UI

## Version 7.4.0 - May 16, 2024
Minor release that updates the Android SDK to 17.8.1 and iOS SDK to 18.2.2

### Changes
- Updated Android SDK to 17.8.1.
- Updated iOS SDK to 18.2.2.

## Version 7.3.2 - May 3, 2024
Patch release that updates the iOS SDK to 18.1.2

### Changes
- Updated iOS SDK to 18.1.2.

## Version 7.3.1 - February 20, 2024
Patch release that updates the Android and iOS SDK to 17.7.3 and fixes a build issue when using Android Gradle Plugin 8+.

### Changes
- Updated Android SDK to 17.7.3.
- Updated iOS SDK to 17.7.3.
- Added a namespace to the Airship module.

## Version 7.3.0 - December 6, 2023
Minor release that updates the iOS SDK to 17.7.0 and Android SDK to 17.6.0 and adds support for notifying the contact of a remote login.

### Changes
- Updated iOS SDK to 17.7.0
- Updated Android SDK to 17.6.0
- Added `Airship.contact.notifyRemoteLogin()` method to notify contact of remote login

## Version 7.2.0 - November 27, 2023
Minor release that improves Feature Flag support on iOS.

### Changes
- Updated iOS SDK to 17.6.1.
- Updated Android SDK to 17.5.0
- Added `Airship.featureFlagManager.trackInteraction(flag)` method to track interaction events
- Fixed crash when using FlutterEngineGroups
- Update iOS Airship Framework Proxy to 5.0.2
- Update Android Airship Framework Proxy to 5.0.2

## Version 7.1.2 - October 6, 2023
Patch release that fixes an exception occuring while listening to the `Airship.messageCenter.onDisplay` event

### Changes
- Fixed an error with Airship.messageCenter.onDisplay

## Version 7.1.1 - September 22, 2023
Patch release that fixes the iOS resetBadge method

### Changes
- Fixed an error with Airship.push.ios.resetBadge()

## Version 7.1.0 - September 13, 2023
Minor release that fixes the iOS resetBadge method, updates to latest SDK versions, and adds a new `editTags` method to batch tag changes.

### Changes
- Fixed Airship.push.ios.resetBadge()
- Updated Android SDK to 17.2.1
- Updated iOS SDK to 17.3.0
- Added `editTags()` method to batch tag changes

## Version 7.0.0 - August 21, 2023
Major release that exposes significantly more of the underlying SDK functionality to Flutter. This release has several breaking changes due to the new modular APIs. Apps should use the migration guide to update [Migration Guide](https://github.com/urbanairship/airship-flutter/blob/main/MIGRATION.md).

### Behavior Changes
- The default Message Center UI will now display unless disabled by `Airship.messageCenter.setAutoLaunchDefaultMessageCenter(false);`
- Apps must now disable the default preference center UI per preference center ID.

### Changes
- Updated to Android SDK 17.1.0 and iOS SDK 17.1.2
- Added feature flag support
- Added new flutter takeOff method with full config support
- Added new methods to control notification options on iOS
- Added new listeners for notification status, push token, and iOS authorized settings
- Added methods to override locale used by Airship messaging
- Added actions component to manually run any actions from the action's framework
- Added method to control the In-App display interval
- Fixed subscription list scope parsing
- Fixed dropping custom events with null values
- Dropped `intl` dependency

## Version 6.3.2 - May 19, 2023
Patch release that updates the intl package dependency to support versions `>=0.15.7 <1.0.0`.
Apps upgrading to Flutter 3.10.0 and higher should update.

## Version 6.3.1 - April 28, 2023 
Patch release that updates the Android SDK to 16.9.2 and fixes an issue with contact subscriptions 
in the example Preference Center.

### Changes
- Updated Android SDK to 16.9.2
- Fixed an issue with contact-level subscription lists in the example Preference Center.

## Version 6.3.0 - March 28, 2023
Minor release that updates the Airship iOS SDK to 16.11.3 and Android SDK to 16.9.1.

## Version 6.2.3 - March 7, 2023
Patch release that fixes a bug with contact subscription list on iOS.

### Changes
- Fixed a bug with `editContactSubscriptionLists` method.

## Version 6.2.2 - February 7, 2023
Patch release with several bug fixes.

### Changes
- Updated iOS SDK to 16.10.7
- Added extended actions pod spec to iOS, enabling rate-app action
- Fixed parsing active notifications on iOS
- Fixed ChannelRegistration event not firing on channel create on iOS
- Fixed push received events on iOS  

## Version 6.2.1 - December 2, 2022
Patch release that updates the Airship iOS SDK to 16.10.5.

## Version 6.2.0 - November 18, 2022
Minor release that updates the Airship iOS SDK to 16.10.3 and Android SDK to 16.8.0.

## Version 6.1.0 - August 3, 2022
Minor release that updates Airship Android SDK to 16.7.0, and iOS SDK to 16.9.0. This also fixes a crash on No Action buttons on iOS.

- Updated Airship Android SDK to 16.7.0.
- Updated Airship iOS SDK to 16.9.0.
- Fix crash on iOS message center buttons with the action: "No Action".

## Version 6.0.1 - July 21, 2022
Patch release that fixes background message handler for silent pushes.

## Version 6.0.0 - June 13, 2022
Major release that supports flutter 3.

- Updated Airship Android SDK to 16.5.1.
- Updated Airship iOS SDK to 16.7.0.
- Updated Flutter SDK to 3.0.2 and dart SDK 2.17.3.
- Fixed code flutter formatting.
- Fixed pubspec to follow Dart file conventions.
- Updated Flutter example to flutter 3.

## Version 5.6.0 - August 3, 2022
Minor release that updates Airship Android SDK to 16.7.0, and iOS SDK to 16.9.0. This also fixes background message handler for silent pushes and a crash on iOS message center buttons with the action: "No Action".

### Changes
- Updated Airship Android SDK to 16.7.0.
- Updated Airship iOS SDK to 16.9.0.
- Fix background message handler for silent pushes on Android.
- Fix crash on iOS message center buttons with the action: "No Action".

## Version 5.5.0 - May 4, 2022
Minor release that updates Airship Android SDK to 16.4.0, and iOS SDK to 16.6.0. These SDK releases fix several issues with Scenes and Surveys. Apps using Scenes & Surveys should update.

- Added support for randomizing Survey responses.
- Added subscription list action.
- Updated localizations. All strings within the SDK are now localized in 48 different languages.
- Improved accessibility with OOTB Message Center UI.
- In-App rules will now attempt to refresh before displaying. This change should reduce the chances of showing out of data or cancelled in-app automations, scenes, or surveys when background refresh is disabled.
- Fixed reporting issue with a single page Scene.
- Fixed rendering issues for Scenes & Surveys.
- Fixed deep links that contain invalid characters by encoding those deep links.
- Fixed crash on Android 8 with Scenes & Surveys.
- Fixed Survey attribute storage on Android.


## Version 5.4.0 - April 4, 2022
Minor release that adds support for registering a handler that will be 
called when a message is received in the background on Android.

### Changes
- Added support for handling background messages on Android
- Updated iOS SDK to 16.5.1

## Version 5.3.0 - March 4, 2022
Minor release that adds support for multi-channel Preference Center.

### Changes
- Added support for multi-channel Preference Center
- Added a method to trigger takeOff from Flutter
- Fixed clearing named user on iOS
- Updated iOS SDK to 16.4.0
- Updated Android SDK to 16.3.3

## Version 5.2.0 - February 10, 2022
Minor release updating iOS SDK and Android SDK to 16.3.0

### Changes
- Updated iOS SDK to 16.3.0
- Updated Android SDK to 16.3.0

## Version 5.1.1 - January 13, 2022
Patch release that updates to latest Airship SDKs and fixes a nullable variable issue
in PushReceivedEvent.

### Changes
- Updated iOS SDK to 16.1.2
- Updated Android SDK to 16.1.1
- Fixed issue when PushReceivedEvent's notification is null

## Version 5.1.0 - December 2, 2021
Minor release updating iOS SDK to 16.1.1 and Android SDK to 16.1.0

### Changes
- Updated iOS SDK to 16.1.1
- Updated Android SDK to 16.1.0

## Version 5.0.1 - November 4, 2021
Patch release that fixes preferences resetting on iOS when upgrading to 5.0.0. This update will restore old preferences that have not been modified new plugin.

**Apps that have migrated to 5.0.0 from an older version should update. Apps currently on version 4.0.0 and below should only migrate to 5.0.1 to avoid the bug in 5.0.0.**

### Changes
- Updated iOS SDK to 16.0.2

## Version 5.0.0 - October 21, 2021

**Due to a bug that mishandles persisted SDK settings, apps that are migrating from plugin 4.4.0 or older should avoid this version and instead use 5.0.1 or newer.**

Major release for Airship Android SDK 16.0.0 and iOS SDK 16.0.1.

### Changes
- Added Privacy Manager methods `enableFeatures`, `disableFeatures`, `setEnabledFeatures`, `getEnabledFeatures` and `isFeatureEnabled` that replace `getDataCollectionEnabled`, `setDataCollectionEnabled`, `getPushTokenRegistrationEnabled` and `setPushTokenRegistrationEnabled`
- Support for OOTB Preference Center
- Xcode 13 is now required.
- CompileSdkVersion 31 and java 8 source compatibility are now required for Android.

## Version 4.4.0 - October 06, 2021
Minor release to add badge methods.

### Changes
- Added `resetBadge`, `setBadge`, `setAutoBadgeEnabled` and `isAutoBadgeEnabled` methods.

## Version 4.3.0 - May 26, 2021
Minor release updating the iOS and Android SDKs to 14.4.1 and 14.4.3. Also adds support for null-safety.

### Changes
- Updated iOS SDK to 14.4.1
- Updated Android SDK to 14.4.3
- Support null-safety
- Updated Android minSdkLevel to API 21

## Version 4.2.0 - April 06, 2021
Minor release updating the iOS and Android SDKs to 14.3.1 and 14.3.0.

### Changes
- Updated iOS SDK to 14.3.1
- Updated Android SDK to 14.3.0
- Added extras to the message center payload

## Version 4.1.1 - February 05, 2021
Patch release to fix some issues with setting attributes on a named user if the named user ID contains invalid URL characters. Applications using attributes with named users that possibly contain invalid URL characters should update.

### Changes
- Updated iOS SDK to 14.2.2
- Fixed attributes updates when the named user has invalid URL characters.

## Version 4.1.0 - December 31, 2020
Minor release adding support for frequency limits and advanced segmentation to In-App Automation and hybrid composition support for InboxMessageView.

### Changes
- Update Airship Android SDK 14.1.1 and iOS SDK 14.2.1
- Added hybrid composition support for InboxMessageView on Android
- Added `refreshInbox` method

## Version 4.0.1 - September 28, 2020
Patch release for Airship Android SDK 14.0.1 and iOS SDK 14.1.2.

### Changes
- Update Airship Android SDK 14.0.1 and iOS SDK 14.1.2
- Fixed events not firing on Android

## Version 4.0.0 - September 21, 2020
Major release for Airship Android SDK 14.0.0 and iOS SDK 14.1.1.

### Changes
- Starting with SDK 14, all landing page and external urls are tested against a URL allow list. The easiest way to go back to 13.x behavior is to add the wildcard symbol `*` to the array under the URLAllowListScopeOpenURL key in your AirshipConfig.plist for iOS, and `urlAllowListScopeOpenUrl = *` to the airshipconfig.properties on Android. Config for `whitelist` has been removed and replaced with:
   iOS: `URLAllowList`, Android: `urlAllowList`
   iOS: `URLAllowListScopeOpenURL`, Android: `urlAllowListScopeOpenUrl`
   iOS: `URLAllowListScopeJavaScriptInterface`, Android: `urlAllowListScopeJavaScriptInterface`
- Xcode 12 is now required.
- Requires Flutter SDK 1.20.4+

## Version 3.1.0 - August 19, 2020
Minor release adding date attributes, custom event properties, named user attributes, support for the new Android plugins APIs and bundling the following SDK updates:

### iOS (Updated iOS SDK from 13.5.2 to 13.5.4)
- Addresses [Dynamic Type](https://developer.apple.com/documentation/uikit/uifont/scaling_fonts_automatically) build warnings and Message Center Inbox UI issues.
- Fixes a crash with Accengage data migration.

### Android (Updated Android SDK from 13.3.1 to 13.3.2)
- Fixes In-App Automation version triggers to only fire on app updates instead of new installs.

## Version 3.0.2 - May 5, 2020
Patch release updating to the latest Airship SDKs and addressing issues with YouTube video support and channel registration on iOS.

### Changes
- Updated iOS SDK to 13.3.0
- Updated Android SDK to 13.1.0
- Fixed YouTube video support in Message Center and HTML In-app messages.
- Fixed channel registration to occur every APNs registration change.

## Version 3.0.1 - March 23, 2020
Patch addressing a regression in iOS SDK 13.1.0 causing channel tag loss
when upgrading from iOS SDK versions prior to 13.0.1. Apps upgrading from airship_flutter plugin
1.0.1 or below should avoid plugin versions 2.1.0 and 3.0.0 in favor of version 3.0.1.

- Updated iOS SDK to 13.1.1

## Version 3.0.0 - February 19, 2020
- Refactored airship.dart to airship_flutter.dart to resolve publish warning. Customers upgrading to 3.0.0 will have to update their plugin imports accordingly, see readme for import instructions.

## Version 2.1.0 - February 7, 2020
- Updated iOS SDK to 13.1.0
- Updated Android SDK to 12.2.0
- Added number attributes support for iOS and Android
- Added data collection controls for iOS and Android
- Added screen tracking for iOS and Android
- Improved cross-platform message view support

## Version 2.0.0 - January 14, 2020
- Renamed plugin package name from airship to airship_flutter
- Updated iOS SDK to 13.0.4
- Updated Android SDK to 12.1.0
- Implemented attributes functionality in iOS and Android

## Version 1.0.1 - December 9, 2019
- Updated iOS SDK to 12.1.2
- Fixed Airship events not properly deserializing in flutter

## Version 1.0.0 - November 1, 2019
- Initial release
