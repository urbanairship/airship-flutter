import UIKit
import Flutter
import airship_flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
//    func registerPlugins(_ registry: (NSObjectProtocol & FlutterPluginRegistry)?) {
//        GeneratedPluginRegistrant.register(with: registry!)
//    }
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    //SwiftAirshipPlugin.setPluginRegistrantCallback(registerPlugins)
    SwiftAirshipPlugin.setPluginRegistrantCallback({ registry in
        SwiftAirshipPlugin.register(with: registry.registrar(forPlugin: "com.airship.flutter")!)
        //GeneratedPluginRegistrant.register(with: registry)
    })
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
