import AirshipFrameworkProxy
import UIKit

@objc(AirshipPluginLoader)
public class AirshipPluginLoader: NSObject, AirshipPluginLoaderProtocol {
    public static func onApplicationDidFinishLaunching(
        launchOptions: [UIApplication.LaunchOptionsKey : Any]?
    ) {
        Task { @MainActor in
            AirshipAutopilot.shared.onLoad()
        }
    }
}
