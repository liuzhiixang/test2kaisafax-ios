//
//  JXIMClient+Helper.m
//

#import "JXIMClient+Helper.h"

#import "JXError+LocalDescription.h"
#import "JXHUD.h"

@implementation JXIMClient (Helper)

// 已废弃
- (void)clientApplication:(UIApplication *)application
        didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
                               appkey:(NSString *)appkey
                         apnsCertName:(NSString *)apnsCertName {
    [self setupAppDelegateToClient];
    [self registerAPNSWithDelegate:application.delegate];

    if (!appkey.length) {
        return;
    }
    JXError *error = [self registerSDKWithAppKey:appkey];
    if (error) {
        [sJXHUD showMessage:[error getLocalDescription] duration:1.4];
    }
}

- (void)initializeSDKWithAppKey:(NSString *)key andUserNotificationCenterDelegate:(id)delegate {
    [self setupAppDelegateToClient];
    [self registerAPNSWithDelegate:delegate];
    
    if (!key.length) {
        return;
    }
    JXError *error = [self registerSDKWithAppKey:key];
    if (error) {
        [sJXHUD showMessage:[error getLocalDescription] duration:1.4];
    }
}

#pragma mark - register apns

- (void)registerAPNSWithDelegate:(id)delegate {
    UIApplication *application = [UIApplication sharedApplication];
    application.applicationIconBadgeNumber = 0;

#if !TARGET_IPHONE_SIMULATOR
    if (IOSVersion >= 10.0) {    // iOS10
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = delegate;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge |
                                                 UNAuthorizationOptionSound |
                                                 UNAuthorizationOptionAlert)
                              completionHandler:^(BOOL granted, NSError *_Nullable error) {
                                  if (!error) {
                                  }
                              }];
        [application registerForRemoteNotifications];
    } else if (IOSVersion >= 8.0) {    // iOS8
        UIUserNotificationSettings *settings = [UIUserNotificationSettings
                settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge |
                                 UIUserNotificationTypeSound
                      categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    } else {    // iOS7
        [application registerForRemoteNotificationTypes:
                             UIRemoteNotificationTypeBadge |
                             UIRemoteNotificationTypeNewsstandContentAvailability |
                             UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert];
    }
#endif
}

//#pragma mark - UNUserNotificationCenterDelegate
//
//- (void)userNotificationCenter:(UNUserNotificationCenter *)center
//didReceiveNotificationResponse:(UNNotificationResponse *)response
//         withCompletionHandler:(void (^)())completionHandler {
//    // FIXME:iOS10 点击调用通知调用该方法
//    completionHandler();
//}

#pragma mark - app delegate notifications

- (void)setupAppDelegateToClient {
    [kDefaultNotificationCenter addObserver:self
                                   selector:@selector(appDidEnterBackground:)
                                       name:UIApplicationDidEnterBackgroundNotification
                                     object:nil];
    [kDefaultNotificationCenter addObserver:self
                                   selector:@selector(appWillEnterForeground:)
                                       name:UIApplicationWillEnterForegroundNotification
                                     object:nil];
    [kDefaultNotificationCenter addObserver:self
                                   selector:@selector(appDidFinishLaunching:)
                                       name:UIApplicationDidFinishLaunchingNotification
                                     object:nil];
    [kDefaultNotificationCenter addObserver:self
                                   selector:@selector(appDidBecomeActive:)
                                       name:UIApplicationDidBecomeActiveNotification
                                     object:nil];
    [kDefaultNotificationCenter addObserver:self
                                   selector:@selector(appWillResignActive:)
                                       name:UIApplicationWillResignActiveNotification
                                     object:nil];
    [kDefaultNotificationCenter addObserver:self
                                   selector:@selector(appDidReceiveMemoryWarning:)
                                       name:UIApplicationDidReceiveMemoryWarningNotification
                                     object:nil];
    [kDefaultNotificationCenter addObserver:self
                                   selector:@selector(appWillTerminate:)
                                       name:UIApplicationWillTerminateNotification
                                     object:nil];
    [kDefaultNotificationCenter addObserver:self
                                   selector:@selector(appProtectedDataWillBecomeUnavailable:)
                                       name:UIApplicationProtectedDataWillBecomeUnavailable
                                     object:nil];
    [kDefaultNotificationCenter addObserver:self
                                   selector:@selector(appProtectedDataDidBecomeAvailable:)
                                       name:UIApplicationProtectedDataDidBecomeAvailable
                                     object:nil];
}

@end
