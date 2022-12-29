import Flutter
import AirshipKit

public class AirshipEventHandler: NSObject,
                                  RegistrationDelegate,
                                  DeepLinkDelegate,
                                  PushNotificationDelegate,
                                  MessageCenterDisplayDelegate {
    func register() {
        Airship.push.registrationDelegate = self
        Airship.shared.deepLinkDelegate = self
        Airship.push.pushNotificationDelegate = self
        MessageCenter.shared.displayDelegate = self
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(inboxUpdated),
                                               name: NSNotification.Name.UAInboxMessageListUpdated,
                                               object: nil)
    }
    
    // MARK: - RegistrationDelegate
    public func apnsRegistrationSucceeded(withDeviceToken deviceToken: Data) {
        if let channelID = Airship.channel.identifier {
            let event = AirshipChannelRegistrationEvent(channelID, registrationToken: Utils.deviceTokenStringFromDeviceToken(deviceToken))
            AirshipEventManager.shared.notify(event)
        }
    }
    
    // MARK: - DeepLinkDelegate
    public func receivedDeepLink(_ url: URL, completionHandler: @escaping () -> Void) {
        let event = AirshipDeepLinkEvent(url.absoluteString)
        AirshipEventManager.shared.notify(event)
        completionHandler()
    }

    // MARK: - PushNotificationDelegate
    public func receivedForegroundNotification(_ userInfo:[AnyHashable : Any], completionHandler: @escaping () -> Void) {
        let event = AirshipPushReceivedEvent(userInfo)
        AirshipEventManager.shared.notify(event)
        completionHandler()
    }

    public func receivedBackgroundNotification(_ userInfo:[AnyHashable : Any], completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let event = AirshipPushReceivedEvent(userInfo)
        AirshipEventManager.shared.notify(event)
        completionHandler(.noData)
    }

    public func receivedNotificationResponse(_ notificationResponse: UNNotificationResponse, completionHandler: @escaping () -> Void) {
        let event = AirshipNotificationResponseEvent(notificationResponse)
        AirshipEventManager.shared.notify(event)
        completionHandler()
    }

    // MARK: - MessageCenterDisplayDelegate
    public func displayMessageCenter(forMessageID messageID: String, animated: Bool) {
        self.showMessage(forID: messageID)
    }

    public func displayMessageCenter(animated: Bool) {
        self.showInbox()
    }

    public func dismissMessageCenter(animated: Bool) {
        //
    }
    
    @objc
    public func showInbox() {
        let event = AirshipShowInboxEvent()
        AirshipEventManager.shared.notify(event)
    }
    
    @objc
    public func showMessage(forID messageID: String) {
        if (MessageCenter.shared.messageList.message(forID: messageID) != nil) {
            self.sendShowInboxMessageEvent(for: messageID)
        } else {
            MessageCenter.shared.messageList.retrieveMessageList {
                self.sendShowInboxMessageEvent(for: messageID)
            }
        }
    }
    
    func sendShowInboxMessageEvent(for messageID: String) {
        let event = AirshipShowInboxMessageEvent(messageID)
        AirshipEventManager.shared.notify(event)
    }

    @objc
    public func inboxUpdated() {
        let event = AirshipInboxUpdatedEvent()
        AirshipEventManager.shared.notify(event)
    }
}

