//
//  AppDelegate.h
//  kaisafax
//
//  Created by semny on 16/6/24.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSMainTabBarVC.h"
#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder < UIApplicationDelegate >

@property (strong, nonatomic) UIWindow *window;
@property (weak, nonatomic) KSMainTabBarVC *tabbarVC;

/**
 *  @author semny
 *
 *  启动主页面
 */
- (KSMainTabBarVC *)startMainPage;

//校验相关的界面启动
//- (UIViewController*)startSecurityPage;
//校验相关的界面启动
- (UIViewController *)startSecurityPageWithBegin:(void (^)(UIViewController *vc))beginStart afterBlock:(void (^)(UIViewController *vc))afterBlock;

@end
