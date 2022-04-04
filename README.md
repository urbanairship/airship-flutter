# Airship Plugin

The Airship Flutter plugin allows using Airship's native iOS and Android APIs with Flutter apps written in Dart.

## Usage

1. Add the airship_flutter dependency to your package's pubspec.yaml file:

```yaml
dependencies:
  airship_flutter: ^5.0.0
```

2. Install your flutter package dependencies by running the following in the command line at your project's root directory:

```sh
$ flutter pub get
```

3. Import airship into your project:

```dart
import 'package:airship_flutter/airship_flutter.dart';
```

### Android Setup

1) Download the Firebase google-services.json file and place it inside android/app.

2) Apply the `com.google.gms.google-services` plugin to the android/app.

3) Create a new `airshipconfig.properties` file with your application’s settings and
place it inside the `android/app/src/main/assets` directory:

```properties
developmentAppKey = Your Development App Key
developmentAppSecret = Your Development App Secret

productionAppKey = Your Production App Key
productionAppSecret = Your Production Secret

# Toggles between the development and production app credentials
# Before submitting your application to an app store set to true
inProduction = false

# LogLevel is "VERBOSE", "DEBUG", "INFO", "WARN", "ERROR" or "ASSERT"
developmentLogLevel = DEBUG
productionLogLevel = ERROR

# Notification customization
notificationIcon = ic_notification
notificationAccentColor = #ff0000

# Optional - Set the default channel
notificationChannel = customChannel
```

4) Optional. In order to be notified of messages that are sent to the device while the app is in the background,
define a `BackgroundMessageHandler` as a top-level function in your app's main.dart file:

```dart
Future<void> backgroundMessageHandler(
    Map<String, dynamic> payload,
    Notification? notification) async { 
  // Handle the message
  print("Received background message: $payload, $notification");
}

void main() {
  Airship.setBackgroundMessageHandler(backgroundMessageHandler);
  runApp(MyApp());
}
```

The handler is executed in a separate background isolate outside the application's main isolate,
so it is not possible to interact with the application UI or update application state from the handler.
Care should be taken to ensure the handler logic completes as soon as possible in order to avoid 
ANRs (Application Not Responding), which may trigger the OS to automatically terminate the process.

### iOS Setup

1) Add the following capabilities for your application target:
  - Push Notification
  - Background Modes > Remote Notifications

2) Create a plist `AirshipConfig.plist` and include it in your application’s target:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>developmentAppKey</key>
  <string>Your Development App Key</string>
  <key>developmentAppSecret</key>
  <string>Your Development App Secret</string>
  <key>productionAppKey</key>
  <string>Your Production App Key</string>
  <key>productionAppSecret</key>
  <string>Your Production App Secret</string>
</dict>
</plist>
```

3) Optional. In order to take advantage of iOS 10 notification attachments, such as images, animated gifs, and
video, you will need to create a notification service extension by following the [iOS Notification Service Extension Guide](https://docs.urbanairship.com/platform/reference/ios-extension/)


### Example Usage

```dart
// Import package
import 'package:airship_flutter/airship.dart';

// Tags
Airship.addTags(["flutter"]);
Airship.removeTags(["some-tag"]);
List<String> tags = await Airship.tags;

// Channel ID
String channelId = await Airship.channelId;

// Enable notifications (prompts on iOS)
Airship.setUserNotificationsEnabled(true);

// Events
Airship.onPushReceived
    .listen((event) => debugPrint('Push Received $event'));

Airship.onNotificationResponse
    .listen((event) => debugPrint('Notification Response $event'));

Airship.onChannelRegistration
    .listen((event) => debugPrint('Channel Registration $event'));

Airship.onDeepLink
    .listen((deepLink) => debugPrint('Deep link: $deeplink'));

```


### Message Center

Message Center support relies on Flutter's mechanism for embedding Android and iOS views.
Note that Hybrid Composition can be enabled on Android by setting InboxMessageView.hybridComposition to true.

#### Example Usage

```dart
// Import package
import 'package:airship_flutter/airship.dart';

// Messages
List<InboxMessage> messages = await Airship.inboxMessages;

// Delete
Airship.deleteInboxMessage(messages[0]);

// Read
Airship.markInboxMessageRead(messages[0]);

// Events
Airship.onInboxUpdated
    .listen((event) => debugPrint('Inbox updated'));

Airship.onShowInbox
    .listen((event) => debugPrint('Navigate to app's inbox'));

Airship.onShowInboxMessage
    .listen((messageId) => debugPrint('Navigate to message $messageId'));

InboxMessage message = messages[0];

@override
Widget build(BuildContext context) {
    return MaterialApp(
            home: Scaffold(
                appBar: AppBar(
                title: const Text('Message: $message.title'),
            ),
            body:  Container(
                child: InboxMessageView(messageId: message.messageId),
                height: 300.0,
            )
        )
    );
}
```
