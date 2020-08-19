# Flutter Plugin Changelog

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
