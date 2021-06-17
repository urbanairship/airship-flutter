//
//  EventPlugin.m
//  Airship
//
//  Created by Ulrich Giberne on 17/05/2021.
//

//#import "EventPlugin.h"
//
//#import <Foundation/Foundation.h>
//
//@implementation EventPlugin {
//    FlutterEngine *_headlessRunner;
//    FlutterMethodChannel *_callbackChannel;
//    FlutterMethodChannel *_mainChannel;
//    NSObject<FlutterPluginRegistrar> *_registrar;
//    NSUserDefaults *_persistentState;
//    NSMutableArray *_eventQueue;
//}
//
//static EventPlugin *instance = nil;
//static FlutterPluginRegistrantCallback registerPlugins = nil;
////static BOOL initialized = NO;
//static BOOL backgroundIsolateRun = NO;
//
//+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
//  @synchronized(self) {
//    if (instance == nil) {
//      NSLog(@"Registering with registrar");
//      instance = [[EventPlugin alloc] init:registrar];
//      [registrar addApplicationDelegate:instance];
//    }
//  }
//}
//
//- (instancetype)init:(NSObject<FlutterPluginRegistrar> *)registrar {
//    self = [super init];
//    NSAssert(self, @"super init cannot be nil");
//
//    // 1. Retrieve NSUserDefaults which will be used to store callback handles
//    // between launches.
//    _persistentState = [NSUserDefaults standardUserDefaults];
//
//    // 3. Initialize the Dart runner which will be used to run the callback
//    // dispatcher.
//    _headlessRunner = [[FlutterEngine alloc]
//                        initWithName:@"EventIsolate"
//                        project:nil
//                        allowHeadlessExecution:YES];
//    _registrar = registrar;
//
//    // 4. Create the method channel used by the Dart interface to invoke
//    // methods and register to listen for method calls.
//    _mainChannel = [FlutterMethodChannel
//                    methodChannelWithName:@"com.airship.flutter/event_plugin"
//                    binaryMessenger:[registrar messenger]];
//    [registrar addMethodCallDelegate:self channel:_mainChannel];
//
//    // 5. Create a second method channel to be used to communicate with the
//    // callback dispatcher. This channel will be registered to listen for
//    // method calls once the callback dispatcher is started.
//    _callbackChannel = [FlutterMethodChannel
//                        methodChannelWithName:@"com.airship.flutter/event_plugin_background"
//                        binaryMessenger:_headlessRunner];
//
//    return self;
//}
//
//- (void)startEventService:(int64_t)handle {
//    NSLog(@"Initializing EventService");
//    [self setCallbackDispatcherHandle:handle];
//    FlutterCallbackInformation *info = [FlutterCallbackCache lookupCallbackInformation:handle];
//    NSAssert(info != nil, @"failed to find callback");
//    NSString *entrypoint = info.callbackName;
//    NSString *uri = info.callbackLibraryPath;
//    [_headlessRunner runWithEntrypoint:entrypoint libraryURI:uri];
//    NSAssert(registerPlugins != nil, @"failed to set registerPlugins");
//
//    // Once our headless runner has been started, we need to register the application's plugins
//    // with the runner in order for them to work on the background isolate. `registerPlugins` is
//    // a callback set from AppDelegate.m in the main application. This callback should register
//    // all relevant plugins (excluding those which require UI).
//    if (!backgroundIsolateRun) {
//        registerPlugins(_headlessRunner);
//    }
//    [_registrar addMethodCallDelegate:self channel:_callbackChannel];
//    backgroundIsolateRun = YES;
//}
//
//- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
//    NSArray *arguments = call.arguments;
//    if ([@"EventPlugin.performAction" isEqualToString:call.method]) {
//        [self startEventService:[arguments[0] longValue]];
//        result(@(YES));
//    } else if ([@"EventService.performed" isEqualToString:call.method]) {
////        @synchronized(self) {
////              initialized = YES;
////                // Send the geofence events that occurred while the background
////                // isolate was initializing.
////                while ([_eventQueue count] > 0) {
////                    NSDictionary* event = _eventQueue[0];
////                    [_eventQueue removeObjectAtIndex:0];
////                    CLRegion* region = [event objectForKey:kRegionKey];
////                    int type = [[event objectForKey:kEventType] intValue];
////                    [self sendLocationEvent:region eventType: type];
////                }
////            }
//        result(nil);
//    } else {
//        result(FlutterMethodNotImplemented);
//    }
//}
//
//- (BOOL)application:(UIApplication *)application
//    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//
//    // Check to see if we're being launched due to a location event.
//    if (launchOptions[UIApplicationLaunchOptionsLocationKey] != nil) {
//        // Restart the headless service.
//        [self startEventService:[self getCallbackDispatcherHandle]];
//    }
//
//    // Note: if we return NO, this vetos the launch of the application.
//    return YES;
//}
//
//- (int64_t)getCallbackDispatcherHandle {
//    id handle = [_persistentState objectForKey:@"callback_dispatcher_handle"];
//    if (handle == nil) {
//        return 0;
//    }
//    return [handle longLongValue];
//}
//
//- (void)setCallbackDispatcherHandle:(int64_t)handle {
//    [_persistentState setObject:[NSNumber numberWithLongLong:handle] forKey:@"callback_dispatcher_handle"];
//}
//
//@end
