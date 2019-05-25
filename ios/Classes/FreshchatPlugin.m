#import "FreshchatPlugin.h"
#import <freshchat/freshchat-Swift.h>

@implementation FreshchatPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFreshchatPlugin registerWithRegistrar:registrar];
}
@end
