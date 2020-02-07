import Foundation

enum AirshipEventType: String {
    case PushReceived = "PUSH_RECEIVED"
    case NotificationResponse = "NOTIFICATION_RESPONSE"
    case ChannelRegistration = "CHANNEL_REGISTRATION"
    case InboxUpdated = "INBOX_UPDATED"
    case ShowInbox = "SHOW_INBOX"
    case ShowInboxMessage = "SHOW_INBOX_MESSAGE"
    case DeepLink = "DEEP_LINK"
    case WebviewLoadStarted = "WEBVIEW_LOAD_STARTED"
    case WebviewLoadFinished = "WEBVIEW_LOAD_FINISHED"
    case WebviewClosed = "WEBVIEW_CLOSED"
}

extension AirshipEventType: CaseIterable {}

protocol AirshipEvent {
    var eventType: AirshipEventType { get }
    var data: Any? { get}
}

