/* Copyright Airship and Contributors */

import Foundation
import AirshipFrameworkProxy
import ActivityKit
import Flutter
import SwiftUI
import Lottie

#if canImport(AirshipCore)
import AirshipCore
#else
import AirshipKit
#endif

/// A helper SwiftUI View to load a Lottie animation from a remote URL asynchronously.
private struct RemoteLottieView: View {
    let url: URL

    @State private var animation: LottieAnimation?

    var body: some View {
        Group {
            if let animation = animation {
                LottieView(animation: animation)
                    .looping()
            } else {
                // Show a placeholder while the animation is loading
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color.black)
        .task {
            // Asynchronously load the animation from the URL when the view appears.
            // The `lottie-ios` library provides a convenient async helper for this.
            self.animation = await LottieAnimation.loadedFrom(url: url)
        }
    }
}


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

        // Register custom Lottie view
        AirshipCustomViewManager.shared.register(name: "lottie-view") { args in
            /// Parse the URL from the Scene using the key "animationUrl" defined in go.airship.com
            if  let animationUrl = args.properties?.object?["animationUrl"]?.string,
                let url = URL(string: animationUrl) {
                AnyView(RemoteLottieView(url: url))
            } else {
                AnyView(
                    Text("Invalid animation URL")
                        .foregroundColor(.white)
                        .background(Color.black)
                )
            }
        }
    }
}
