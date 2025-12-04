# Airship Flutter

The official Airship Flutter plugin for iOS and Android.

[![pub package](https://img.shields.io/pub/v/airship_flutter.svg)](https://pub.dev/packages/airship_flutter)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Features

- **Push Notifications** - Rich, interactive push notifications with deep linking
- **Live Activities & Live Updates** - Real-time content updates on iOS Lock Screen and Android notifications
- **In-App Experiences** - Contextual messaging, automation, and Scenes
- **Embedded Content** - Render Airship Scenes directly in your Flutter app
- **Message Center** - Persistent inbox for rich messages with HTML, video, and interactive content
- **Preference Center** - User preference management
- **Feature Flags** - Dynamic feature toggles and experimentation
- **Analytics** - Comprehensive user behavior tracking
- **Contacts** - User identification and contact management
- **Tags, Attributes & Subscription Lists** - User segmentation, personalization, and subscription management
- **Privacy Controls** - Granular data collection and feature management

## Quick Start

### Installation

Add the dependency to your `pubspec.yaml`:
```yaml
dependencies:
  airship_flutter: ^11.0.0
```

Then run:
```bash
flutter pub get
```

### Platform Setup

#### iOS

Add your `AirshipConfig.plist` to your iOS project's `Runner` directory with your Airship credentials:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>developmentAppKey</key>
  <string>YOUR_DEV_APP_KEY</string>
  <key>developmentAppSecret</key>
  <string>YOUR_DEV_APP_SECRET</string>
  <key>productionAppKey</key>
  <string>YOUR_PROD_APP_KEY</string>
  <key>productionAppSecret</key>
  <string>YOUR_PROD_APP_SECRET</string>
</dict>
</plist>
```

#### Android

Add your `airshipconfig.properties` to `android/app/src/main/assets/`:
```properties
developmentAppKey = YOUR_DEV_APP_KEY
developmentAppSecret = YOUR_DEV_APP_SECRET
productionAppKey = YOUR_PROD_APP_KEY
productionAppSecret = YOUR_PROD_APP_SECRET
```

### Initialization

Initialize Airship in your app:
```dart
import 'package:airship_flutter/airship_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Take off with config file credentials
  await Airship.takeOff(AirshipConfig(
    defaultEnvironment: ConfigEnvironment(
      appKey: "YOUR_APP_KEY",
      appSecret: "YOUR_APP_SECRET",
    ),
  ));

  // Enable push notifications
  await Airship.push.setUserNotificationsEnabled(true);

  runApp(MyApp());
}
```

For a more detailed setup guide, please see the full [Getting Started Documentation](https://docs.airship.com/platform/mobile/setup/sdk/flutter/).

## Supported Versions

| Airship Flutter Version | Airship SDK Version | Flutter Version | Support Status |
| :---------------------- | :------------------ | :-------------- | :------------- |
| **11.x**                | 20.x                | 3.0.2+          | **Active**     |
| **10.x**                | 19.x                | 3.0.2+          | Maintenance    |
| **9.x**                 | 18.x                | 3.0.2+          | Unsupported    |

*Table last updated: December 3, 2025*

## Requirements

### iOS
- iOS 16.0+
- Xcode 14+
- Swift 5.0+

### Android
- minSdkVersion 21
- compileSdkVersion 35
- Java 17
- Kotlin 2.0.21+

## Resources

- **[Documentation](https://docs.airship.com/platform/mobile/setup/sdk/flutter/)** - Complete SDK integration guides
- **[API Reference](https://docs.airship.com/reference/libraries/flutter/latest/)** - Detailed API documentation
- **[GitHub Issues](https://github.com/urbanairship/airship-flutter/issues)** - Report bugs and request features
- **[Changelog](CHANGELOG.md)** - Release notes and version history
- **[Migration Guide](MIGRATION.md)** - Upgrade guides between major versions

## Issues

Please visit https://support.airship.com/ for any issues integrating or using this plugin.
