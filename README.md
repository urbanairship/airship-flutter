# Airship Plugin

Preview of the Airship Flutter plugin.

This plugin is currently in development or published. APIs will most likely change before the first
major release.

## Status

Feature Status:
- [x] Tags
- [x] Notifications
- [x] Deep links
- [x] Inbox
- [x] Named User
- [x] Push Events
- [ ] Custom events
- [ ] Notification management
- [ ] Tag Groups

## Usage

This plugin is not yet published, so you will have to use the current master repo as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).
```
  airship:
    git: git://github.com/urbanairship/airship-flutter.git
```

### Android Setup

1) Download the Firebase google-services.json file and place it inside android/app.

2) Apply the `com.google.gms.google-services` plugin to the android/app.

3) Create a new `airshipconfig.properties` file with your application’s settings and
place it inside the android/app/src/main/assets directory:

```
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
   notificationChannel = "customChannel"
```

### iOS Setup

1) Add the following capabilities for your application target:
  - Push Notification
  - Background Modes > Remote Notifications

2) Create a plist `AirshipConfig.plist` and include it in your application’s target:
```
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

```
// Import package
import 'package:airship/airship.dart';

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


### Message Center Example Usage

```
// Import package
import 'package:airship/airship.dart';

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

void onInboxMessageViewCreated(InboxMessageViewController controller) {
    controller.loadMessage(message);
}

@override
Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
            title: const Text('Message: $message.title'),
        ),
        body:  Container(
            child: InboxMessageView(onViewCreated: onInboxMessageViewCreated),
            height: 300.0,
        )
    ));
}
```
