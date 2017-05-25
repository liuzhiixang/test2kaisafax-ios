//
//  JXIMClient+Helper.h
//

#import <UserNotifications/UserNotifications.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "JXIMClient.h"
#import "JXClientDelegate.h"
#import "JXMacros.h"

@interface JXIMClient (Helper) 

#pragma mark - init client

- (void)clientApplication:(UIApplication *)application
        didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
                               appkey:(NSString *)appkey
                         apnsCertName:(NSString *)apnsCertName
                DEPRECATED("已废弃, 使用initializeSDKWithAppKey:andUserNotificationCenterDelegate:替代");


/**
 初始化佳信SDK及注册远程推送

 @param key appkey
 @param delegate 针对iOS 10,传入UserNotificationCenter的代理
 */
- (void)initializeSDKWithAppKey:(NSString *)key andUserNotificationCenterDelegate:(id)delegate;

@end
