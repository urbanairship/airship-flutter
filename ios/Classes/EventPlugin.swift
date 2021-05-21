import Flutter
import Foundation

var instance: EventPlugin? = nil
var registerPlugins: FlutterPluginRegistrantCallback? = nil
//static BOOL initialized = NO;
var backgroundIsolateRun = false

//public class EventPlugin : NSObject, FlutterPlugin {
//    private var headlessRunner: FlutterEngine?
//    private var callbackChannel: FlutterMethodChannel?
//    private var mainChannel: FlutterMethodChannel?
//    private weak var registrar: (NSObjectProtocol & FlutterPluginRegistrar)?
//    private var persistentState: UserDefaults?
//    private var eventQueue: [AnyHashable]?
//
//    public class func register(with registrar: (NSObjectProtocol & FlutterPluginRegistrar)) {
//        let lockQueue = DispatchQueue(label: "self")
//        lockQueue.sync {
//            if instance == nil {
//                print("Registering with registrar")
//                instance = EventPlugin(registrar)
//                registrar.addApplicationDelegate(instance!)
//            }
//        }
//    }
//
//    public init(_ test: String) {
//        super.init()
//
//        // 1. Retrieve NSUserDefaults which will be used to store callback handles
//        // between launches.
//        persistentState = UserDefaults.standard
//    }
//
//    init(_ registrar: (NSObjectProtocol & FlutterPluginRegistrar)?) {
//        super.init()
//
//        // 1. Retrieve NSUserDefaults which will be used to store callback handles
//        // between launches.
//        persistentState = UserDefaults.standard
//
//        // 3. Initialize the Dart runner which will be used to run the callback
//        // dispatcher.
//        headlessRunner = FlutterEngine(
//            name: "EventIsolate",
//            project: nil,
//            allowHeadlessExecution: true)
//        self.registrar = registrar
//
//        // 4. Create the method channel used by the Dart interface to invoke
//        // methods and register to listen for method calls.
//        mainChannel = FlutterMethodChannel(
//            name: "com.airship.flutter/event_plugin",
//            binaryMessenger: registrar?.messenger() as! FlutterBinaryMessenger)
//        registrar?.addMethodCallDelegate(self, channel: mainChannel!)
//
//        // 5. Create a second method channel to be used to communicate with the
//        // callback dispatcher. This channel will be registered to listen for
//        // method calls once the callback dispatcher is started.
//        callbackChannel = FlutterMethodChannel(
//                            name:"com.airship.flutter/event_plugin_background",
//            binaryMessenger: headlessRunner as! FlutterBinaryMessenger)
//    }
//
//    // TODO Move things directly into the AirshipPlugin
//    public func startEventService(_ handle: Int64) {
//        print("Initializing EventService")
//        setCallbackDispatcherHandle(handle)
//        let info = FlutterCallbackCache.lookupCallbackInformation(handle)
//        assert(info != nil, "failed to find callback")
//        let entrypoint = info?.callbackName
//        let uri = info?.callbackLibraryPath
//        headlessRunner?.run(withEntrypoint: entrypoint, libraryURI: uri)
//        assert(registerPlugins != nil, "failed to set registerPlugins")
//
//        // Once our headless runner has been started, we need to register the application's plugins
//        // with the runner in order for them to work on the background isolate. `registerPlugins` is
//        // a callback set from AppDelegate.m in the main application. This callback should register
//        // all relevant plugins (excluding those which require UI).
//        if !backgroundIsolateRun {
//            registerPlugins?(headlessRunner!)
//        }
//        registrar?.addMethodCallDelegate(self, channel: callbackChannel!)
//        backgroundIsolateRun = true
//    }
//
//    public func handle(_ call: FlutterMethodCall, result: FlutterResult) {
//        let arguments = call.arguments as? NSArray
//        if "EventPlugin.performAction" == call.method {
//            startEventService(Int64((arguments?[0] as! NSNumber)))
//            result(NSNumber(value: true))
//        } else if "EventService.performed" == call.method {
//
//            result(nil)
//        } else {
//            result(FlutterMethodNotImplemented)
//        }
//    }
//
//    private func application(
//        _ application: UIApplication,
//        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
//    ) -> Bool {
//
//        // Check to see if we're being launched due to a location event.
//        if launchOptions?[UIApplication.LaunchOptionsKey.location] != nil {
//            // Restart the headless service.
//            startEventService(getCallbackDispatcherHandle())
//        }
//
//        // Note: if we return NO, this vetos the launch of the application.
//        return true
//    }
//
//    func getCallbackDispatcherHandle() -> Int64 {
//        let handle = persistentState?.object(forKey: "callback_dispatcher_handle")
//        if handle == nil {
//            return 0
//        }
//        return (handle as? NSNumber)?.int64Value ?? 0
//    }
//
//    func setCallbackDispatcherHandle(_ handle: Int64) {
//        persistentState?.set(NSNumber(value: handle), forKey: "callback_dispatcher_handle")
//    }
//}
