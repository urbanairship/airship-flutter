package com.airship.flutter

import com.airship.flutter.events.DeepLinkEvent
import com.airship.flutter.events.InboxUpdatedEvent
import com.airship.flutter.events.ShowInboxEvent
import com.airship.flutter.events.ShowInboxMessageEvent
import com.urbanairship.Autopilot
import com.urbanairship.UAirship
import com.urbanairship.actions.ActionArguments
import com.urbanairship.actions.ActionResult
import com.urbanairship.actions.DeepLinkAction
import com.urbanairship.actions.OpenRichPushInboxAction
import com.urbanairship.json.JsonValue

class FlutterAutopilot : Autopilot() {

    override fun onAirshipReady(airship: UAirship) {
        super.onAirshipReady(airship)

        // Register a listener for inbox update event
        airship.inbox.addListener {
            EventManager.shared.notifyEvent(InboxUpdatedEvent())
        }

        // Deep links
        airship.actionRegistry.getEntry(DeepLinkAction.DEFAULT_REGISTRY_NAME).defaultAction = object : DeepLinkAction() {
            override fun perform(arguments: ActionArguments): ActionResult {
                val deepLink = arguments.value.string
                if (deepLink != null) {
                    EventManager.shared.notifyEvent(DeepLinkEvent(deepLink))
                }
                return ActionResult.newResult(arguments.value)
            }
        }

        // Inbox
        airship.actionRegistry.getEntry(OpenRichPushInboxAction.DEFAULT_REGISTRY_NAME).defaultAction = object : OpenRichPushInboxAction() {
            override fun perform(arguments: ActionArguments): ActionResult {
                val messageId = arguments.value.string
                if (messageId != null) {
                    EventManager.shared.notifyEvent(ShowInboxMessageEvent(messageId))
                } else {
                    EventManager.shared.notifyEvent(ShowInboxEvent())
                }

                return ActionResult.newEmptyResult()
            }
        }
    }
}