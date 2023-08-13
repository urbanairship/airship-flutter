# Migration Guide

# 6.x to 7.x

### Min iOS Version

This version of the plugin now requires iOS 14+ as the min deployment target and Xcode 14.3+.

## API Changes

### Methods

The API is now divided up into functional components that can be accessed from the `Airship` instance. Use the table
for replacements.

| 6.x | 7.x                                                                                                                      |
|---|--------------------------------------------------------------------------------------------------------------------------|
| Airship.takeOff(String appKey, String appSecret) : Future<bool> | Airship.takeOff(AirshipConfig config) : Future<bool>                                                                     |
| Airship.channelId : Future<String> | Airship.channel.identifier : Future<String>                                                                              |
| Airship.editChannelSubscriptionLists() : SubscriptionListEditor | Airship.channel.editSubscriptionLists() : SubscriptionListEditor                                                         |
| Airship.onChannelRegistration : Stream<ChannelEvent> | Airship.channel.onChannelCreated : Stream<ChannelCreatedEvent>                                                           |
| Airship.getSubscriptionLists(List<String> subscriptionListTypes) : Future<SubscriptionList> (if types are "channel") | Airship.channel.subscriptionLists : Future<List<String>>                                                                 |
| Airship.addTags(List<String> tags) : Future<void> | Airship.channel.addTags(List<String> tags) : Future<void>                                                                |
| Airship.removeTags(List<String> tags) : Future<void> | Airship.channel.removeTags(List<String> tags) : Future<void>                                                             |
| Airship.tags : Future<List<String>> | Airship.channel.tags : Future<List<String>>                                                                              |
| Airship.enableChannelCreation() : Future<void> | Airship.channel.enableChannelCreation() : Future<void>                                                                   |
| Airship.editAttributes() : AttributeEditor | Airship.channel.editAttributes() : AttributeEditor                                                                       |
| Airship.editChannelTagGroups() : TagGroupEditor | Airship.channel.editTagGroups() : TagGroupEditor                                                                         |
| Airship.userNotificationsEnabled : Future<bool?> | Airship.push.isUserNotificationsEnabled : Future<bool>                                                                   |
| Airship.setUserNotificationsEnabled : Future<bool?> | Airship.push.setUserNotificationsEnabled : Future<void>                                                                  |
| Airship.activeNotifications : Future<List<Notification>> | Airship.push.activeNotifications : Future<List<PushPayload>>                                                             |
| Airship.clearNotification(String notification) : Future<void> | Airship.push.clearNotification(String notification) : Future<void>                                                       |
| Airship.clearNotifications() : Future<void> | Airship.push.clearNotifications() : Future<void>                                                                         |
| Airship.onPushReceived : Stream<PushReceivedEvent> | Airship.push.onPushReceived : Stream<PushReceivedEvent>                                                                  |
| Airship.onNotificationResponse : Stream<NotificationResponseEvent> | Airship.push.onNotificationResponse : Stream<NotificationResponseEvent>                                                  |
| Airship.setBackgroundMessageHandler(BackgroundMessageHandler handler) : Future<void> | Airship.push.android.setBackgroundPushReceivedHandler(AndroidBackgroundPushReceivedHandler handler) : Future<void>       |
| Airship.isAutoBadgeEnabled() : Future<bool> | Airship.push.iOS.isAutoBadgeEnabled() : Future<bool>                                                                     |
| Airship.setAutoBadgeEnabled(bool enabled) : Future<void> | Airship.push.iOS.setAutoBadgeEnabled(bool enabled) : Future<void>                                                        |
| Airship.setBadge(int badge) : Future<void> | Airship.push.iOS.setBadge(int badge) : Future<void>                                                                      |
| Airship.resetBadge() : Future<void> | Airship.push.iOS.resetBadge() : Future<void>                                                                             |
| Airship.getSubscriptionLists(List<String> subscriptionListTypes) : Future<SubscriptionList> (if types are "contact") | Airship.contact.subscriptionLists : Future<Map<String, List<ChannelScope>>>                                              |
| Airship.namedUser : Future<String?> | Airship.contact.namedUserId : Future<String?>                                                                            |
| Airship.setNamedUser(String? namedUser) : Future<void> | Airship.contact.identify(String namedUser) : Future<void>                                                                |
| Airship.editContactSubscriptionLists() : ScopedSubscriptionListEditor | Airship.contact.editSubscriptionLists() : ScopedSubscriptionListEditor                                                   |
| Airship.editNamedUserTagGroups() : TagGroupEditor | Airship.contact.editTagGroups() : TagGroupEditor                                                                         |
| Airship.setInAppAutomationPaused(bool paused) : Future<void> | Airship.inApp.setPaused(bool paused) : Future<void>                                                                      |
| Airship.getInAppAutomationPaused : Future<void> | Airship.inApp.isPaused : Future<bool>                                                                                    |
| Airship.inboxMessages : Future<List<InboxMessage>> | Airship.messageCenter.messages : Future<List<InboxMessage>>                                                              |
| Airship.markInboxMessageRead(InboxMessage message) : Future<void> | Airship.messageCenter.markRead(String messageId) : Future<void>                                                          |
| Airship.deleteInboxMessage(InboxMessage message) : Future<void> | Airship.messageCenter.deleteMessage(String messageId) : Future<void>                                                     |
| Airship.refreshInbox() : Future<bool?> | Airship.messageCenter.refreshInbox() : Future<bool?>                                                                     |
| Airship.onInboxUpdated : Stream<void>? | Airship.messageCenter.onInboxUpdated : Stream<MessageCenterUpdatedEvent>                                                 |
| Airship.onShowInbox : Stream<void>? | Airship.messageCenter.onDisplay : Stream<DisplayMessageCenterEvent>                                                      |
| Airship.enableFeatures(List<String> features) : Future<void> | Airship.privacyManager.enableFeatures(List<Feature> features) : Future<void>                                             |
| Airship.disableFeatures(List<String> features) : Future<void> | Airship.privacyManager.disableFeatures(List<Feature> features) : Future<void>                                            |
| Airship.setEnabledFeatures(List<String> features) : Future<void> | Airship.privacyManager.setEnabledFeatures(List<Feature> features) : Future<void>                                         |
| Airship.getEnabledFeatures() : Future<List<String>> | Airship.privacyManager.enabledFeatures : Future<List<Feature>>                                                           |
| Airship.isFeatureEnabled(String feature) : Future<bool> | Airship.privacyManager.isFeaturesEnabled(List<Feature> features) : Future<bool>                                          |
| Airship.getPreferenceCenterConfig(String preferenceCenterID) : Future<PreferenceCenterConfig?> | Airship.preferenceCenter.getConfig(String preferenceCenterID) : Future<PreferenceCenterConfig?>                          |
| Airship.setAutoLaunchDefaultPreferenceCenter(bool enabled) : Future<void> | Airship.preferenceCenter.setAutoLaunchDefaultPreferenceCenter(String preferenceCenterID, bool autoLaunch) : Future<void> |
| Airship.openPreferenceCenter(String preferenceCenterID) : Future<void> | Airship.preferenceCenter.display(String preferenceCenterID) : Future<void>                                               |
| Airship.onShowPreferenceCenter : Stream<String?> | Airship.preferenceCenter.onDisplay : Stream<DisplayPreferenceCenterEvent>                                                |
| Airship.trackScreen(String screen) : Future<void> | Airship.analytics.trackScreen(String screen) : Future<void>                                                              |
| Airship.addEvent(CustomEvent event) : Future<void> | Airship.analytics.addEvent(CustomEvent event) : Future<void>                                                             |

## Message Center

### Events
`Airship.onShowInbox` and `Airship.onShowInboxMessage` have been merged into a single Stream `Airship.messageCenter.onDisplay`. The even will now contain a property with an optional messageId if the a particular message should be displayed.

### Display Message Center
In 7.0.0, the default Message Center will display unless disabled with `Airship.messageCenter.setAutoLaunchDefaultMessageCenter(false);`. Display events will not be emitted if the default message center UI is enabled.

## Preference Center

Disabling auto launching the default preference center UI from past versions will not carry forward to plugin 7.0.0. Instead, you will now have to disable the default preference center UI per preference center ID.

