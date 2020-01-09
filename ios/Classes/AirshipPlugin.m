#import "AirshipPlugin.h"
#import <airship_flutter/airship_flutter-Swift.h>

@implementation AirshipPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAirshipPlugin registerWithRegistrar:registrar];
}
@end
