#import "AirshipPlugin.h"
#import <airship_flutter/airship_flutter-Swift.h>

@implementation AirshipPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    [SwiftAirshipPlugin registerWithRegistrar:registrar];
}

+ (void)load {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
       [center addObserverForName:UIApplicationDidFinishLaunchingNotification
                                                         object:nil
                                                          queue:nil usingBlock:^(NSNotification * _Nonnull note) {
           [FlutterAirshipAutopilot.shared onLoadWithLaunchOptions:note.userInfo];
    }];
}
@end
