#import "AirshipPlugin.h"
#import <airship/airship-Swift.h>

@implementation AirshipPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAirshipPlugin registerWithRegistrar:registrar];
}
@end
