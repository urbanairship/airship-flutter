/* Copyright Airship and Contributors */

import Foundation
import AirshipFrameworkProxy
import ActivityKit

#if canImport(AirshipCore)
import AirshipCore
#else
import AirshipKit
#endif

@objc(AirshipPluginExtender)
public class AirshipPluginExtender: NSObject, AirshipPluginExtenderProtocol {

  /// Called on the same run loop when Airship takesOff.
  @MainActor
  public static func onAirshipReady() {

    if #available(iOS 16.1, *) {
      // Throws if setup is called more than once
      try? LiveActivityManager.shared.setup { configurator in

        // Register each activity type
        await configurator.register(forType: Activity<ExampleWidgetsAttributes>.self) { attributes in
          // Track this property as the Airship name for updates
          attributes.name
        }
      }
    }
  }
}
