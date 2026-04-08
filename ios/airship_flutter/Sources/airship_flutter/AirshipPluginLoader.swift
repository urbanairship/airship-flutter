import AirshipFrameworkProxy

@objc(AirshipPluginLoader)
@MainActor
public class AirshipPluginLoader: NSObject, AirshipPluginLoaderProtocol {
    public static func onLoad() {
        AirshipAutopilot.shared.onLoad()
    }
}
