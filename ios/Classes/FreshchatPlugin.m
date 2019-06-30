#import "FreshchatPlugin.h"
#import "FreshchatSDK.h"

static const NSString* METHOD_INIT = @"init";
static const NSString* METHOD_IDENTIFY_USER = @"identifyUser";
static const NSString* METHOD_UPDATE_USER_INFO = @"updateUserInfo";
static const NSString* METHOD_RESET_USER = @"reset";
static const NSString* METHOD_SHOW_CONVERSATIONS = @"showConversations";
static const NSString* METHOD_SHOW_FAQS = @"showFAQs";
static const NSString* METHOD_GET_UNREAD_MESSAGE_COUNT = @"getUnreadMsgCount";
static const NSString* METHOD_SETUP_PUSH_NOTIFICATIONS = @"setupPushNotifications";

@implementation FreshchatPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"freshchat"
            binaryMessenger:[registrar messenger]];
  FreshchatPlugin* instance = [[FreshchatPlugin alloc] initWithRegistrar:registrar];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  self = [super init];
  NSAssert(self, @"super init cannot be nil");
  _registrar = registrar;
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  id viewController = [UIApplication sharedApplication].delegate.window.rootViewController;

  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  }
  else if ([METHOD_INIT isEqualToString:call.method]) {
      NSString* appID = call.arguments[@"appID"];
      NSString* appKey = call.arguments[@"appKey"];
      
      FreshchatConfig* freshchatConfig = [[FreshchatConfig alloc] initWithAppID:appID andAppKey:appKey];
      
      freshchatConfig.cameraCaptureEnabled = false;
      freshchatConfig.responseExpectationVisible = NO; //set NO to hide it if you want to hide the response expectation for the channel

      // NSString* key = [_registrar lookupKeyForAsset:@"FCTheme_New"];
      // NSString* path = [[NSBundle mainBundle] pathForResource:key ofType:nil];
      freshchatConfig.themeName = @"FCTheme_New";
      
      [[Freshchat sharedInstance] initWithConfig:freshchatConfig];
      
      result([NSNumber numberWithBool:YES]);
  }
  else if ([METHOD_SHOW_CONVERSATIONS isEqualToString:call.method]) {
      NSArray* tags = call.arguments[@"tags"];
      NSString* title = call.arguments[@"title"];
      if (tags.count > 0) {
          ConversationOptions* convOptions = [ConversationOptions new];
          [convOptions filterByTags:tags withTitle:title];
          [[Freshchat sharedInstance] showConversations:viewController withOptions:convOptions];
      } else {
          [[Freshchat sharedInstance] showConversations:viewController];
      }
      result([NSNumber numberWithBool:YES]);
  }
  else if ([METHOD_UPDATE_USER_INFO isEqualToString:call.method]) {
      NSString* firstName = call.arguments[@"firstName"];
      NSString* email = call.arguments[@"email"];
      FreshchatUser* freshchatUser = [FreshchatUser sharedInstance];
      
      if (firstName != nil && [firstName length] > 0) {
          freshchatUser.firstName = firstName;
      }
      
      freshchatUser.email = email;
      
      [[Freshchat sharedInstance] setUser:freshchatUser];
      
      result([NSNumber numberWithBool:YES]);
  }
  else if ([METHOD_IDENTIFY_USER isEqualToString:call.method]) {
      NSString* externalId = call.arguments[@"externalID"];
      NSString* restoreId = call.arguments[@"restoreID"];
      
      if ([restoreId isEqualToString:@""]) {
          [[Freshchat sharedInstance] identifyUserWithExternalID:externalId restoreID:nil];
          restoreId = [FreshchatUser sharedInstance].restoreID;
      }
      else {
          [[Freshchat sharedInstance] identifyUserWithExternalID:externalId restoreID:restoreId];
      }
      
      result(restoreId);
  }
  else if ([METHOD_SHOW_FAQS isEqualToString:call.method]) {
      const NSNumber* showFaqCategoriesAsGrid = call.arguments[@"showFaqCategoriesAsGrid"];
      const NSNumber* showContactUsOnAppBar = call.arguments[@"showContactUsOnAppBar"];
      const NSNumber* showContactUsOnFaqScreens = call.arguments[@"showContactUsOnFaqScreens"];
      
      //todo: seems not used on ios.
      //const NSNumber* showContactUsOnFaqNotHelpful = call.arguments[@"showContactUsOnFaqNotHelpful"];
      
      FAQOptions* faqOptions = [FAQOptions new];
      faqOptions.showFaqCategoriesAsGrid = showFaqCategoriesAsGrid;
      faqOptions.showContactUsOnAppBar = showContactUsOnAppBar;
      faqOptions.showContactUsOnFaqScreens = showContactUsOnFaqScreens;
      
      [[Freshchat sharedInstance] showFAQs:viewController withOptions:faqOptions];
      
      result([NSNumber numberWithBool:YES]);
  }
  else if ([METHOD_GET_UNREAD_MESSAGE_COUNT isEqualToString:call.method]) {
      /* If you want to indicate to the user that he has unread messages in his inbox, you can retrieve the unread count to display. */
      //returns an int indicating the of number of unread messages for the user
      [[Freshchat sharedInstance]unreadCountWithCompletion:^(NSInteger count) {
          NSLog(@"your unread count : %d", (int)count);
          result([NSNumber numberWithLong:count]);
      }];
  }
  else if ([METHOD_SETUP_PUSH_NOTIFICATIONS isEqualToString:call.method]) {
      const NSString* token = call.arguments[@"token"];
      [[Freshchat sharedInstance] setPushRegistrationToken:token];
      result([NSNumber numberWithBool:YES]);
  }
  else if ([METHOD_RESET_USER isEqualToString:call.method]) {
      [[Freshchat sharedInstance] resetUserWithCompletion:^{
          result([NSNumber numberWithBool:YES]);
      }];
  }
  else {
    result(FlutterMethodNotImplemented);
  }
}
@end
