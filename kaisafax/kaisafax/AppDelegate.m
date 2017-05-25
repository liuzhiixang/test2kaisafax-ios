//
//  AppDelegate.m
//  kaisafax
//
//  Created by semny on 16/6/24.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "AppDelegate.h"
#import "KSDBUtils.h"
//#import "KSMainVC.h"
//#import "KSNavigationVC.h"
#import "KSADStartVC.h"
#import "KSLaunchVC.h"
#import "KSMainTabBarVC.h"
#import "KSStatisticalMgr.h"
#import <IQKeyboardManager/IQKeyboardManager.h>

#import "KSServerMgr.h"
#import "KSUserMgr.h"
#import "SocialService.h"

#import "KSADMgr.h"
#import "KSADPushVC.h"
#import "KSKeychain.h"

#import "KSGestureSettingVC.h"
#import "KSGestureVerifyVC.h"
#import "KSTouchIdVC.h"
#import "SQGestureMgr.h"
#import "SQTouchLockMgr.h"

//#import "JXLocalPushManager.h"
//
#import "JXMCSUserManager.h"
#import "JXMcsChatViewController.h"

#import "KSReportMgr.h"

//#import "PerformanceMonitor.h"

@interface AppDelegate () <UITabBarControllerDelegate, KSBLDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Override point for customization after application launch.

	//卡顿检测
	//    [[PerformanceMonitor sharedInstance] startMonitor];

	//设置NUI配置
	[self setNUIConfig];

	//配置佳信客服
	[self configJXCustomerService:application launchOptions:launchOptions];

	//登录佳信客服
	[self loginJXCustomer];

	//开启统计
	[[KSStatisticalMgr sharedInstance] start];

	//初始化数据库
	[KSDBUtils startInitDB];

	//注册统计平台
	if (!TARGET_IPHONE_SIMULATOR)
	{
		[[SocialService sharedInstance] registerPlatforms];
	}

	//检测服务器状态
	[[KSServerMgr sharedInstance] doGetServerStatus];

	//TODO TEST 在这里检测获取用户数据
	//    [USER_MGR doRefreshSessionId];
	[USER_MGR doGetUserInfo];
	[USER_MGR updateUserAssets];

	//上报设备信息
	[[KSReportMgr sharedInstance] doSendDeviceReport];

	//主window
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	//判断是否有广告
	BOOL needShowAD			 = [self checkADStatus];
	BOOL needShowPushAD		 = [self checkPushADStatus];
	UIViewController *rootVC = nil;
	if (needShowAD)
	{
		//启动的本地广告页
		rootVC = [self configStartADPage];
	}
	else if (needShowPushAD)
	{
		//远程广告
		rootVC = [self configPushADPage];
	}
	else
	{
		rootVC = [self configSecurityPageWithNeedStartMain:YES afterBlock:nil];
	}
	self.window.rootViewController = rootVC;
	self.window.backgroundColor	= [UIColor whiteColor];
	[self.window makeKeyAndVisible];

	//启动图界面
	[self showLaunchPage];

	//广告
	//    [KSADMgr presentADPageBy:_tabbarVC];
	//下载广告数据
	[[KSADMgr sharedInstance] doGetServerADConfig];

	//2.自适应屏幕键盘控件
	IQKeyboardManager *manager					= [IQKeyboardManager sharedManager];
	manager.enable								= YES;
	manager.shouldResignOnTouchOutside			= YES;
	manager.shouldToolbarUsesTextFieldTintColor = YES;
	manager.enableAutoToolbar					= YES;

	//判断是否为第一次启动
	NSNumber *flagNum = [USER_DEFAULT objectForKey:@"hasStart"];
	if (!flagNum || !flagNum.boolValue)
	{
		// Delete values from keychain here
		[KSKeychain deleteAllKeychain];
		//同步启动标志
		[USER_DEFAULT setValue:@(YES) forKey:@"hasStart"];
		[USER_DEFAULT synchronize];
	}

	//登录态的注册
	@WeakObj(self);
	[[[NSNotificationCenter defaultCenter] rac_addObserverForName:KLoginStatusNotification object:nil] subscribeNext:^(NSNotification *notify) {
		[weakself loginStatusChanged:notify];
	}];

	return YES;
}

//- (void)testDevice
//{
//    //友盟的测试设备的UUID生成
//    Class cls = NSClassFromString(@"UMANUtil");
//    SEL deviceIDSelector = @selector(openUDIDString);
//    NSString *deviceID = nil;
//    if(cls && [cls respondsToSelector:deviceIDSelector]){
//        deviceID = [cls performSelector:deviceIDSelector];
//    }
//    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:@{@"oid" : deviceID}
//                                                       options:NSJSONWritingPrettyPrinted
//                                                         error:nil];
//
//    NSLog(@"%@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
//}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	//    self.window.hidden = YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	//    self.window.hidden = NO;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
	BOOL flag = NO;
	if (!url)
	{
		return flag;
	}

	NSString *scheme = [url scheme];
	if (scheme && scheme.length > 0)
	{
		SocialService *snsService = [SocialService sharedInstance];
		flag					  = [snsService handleOpenURL:url sourceApplication:sourceApplication annotation:annotation];
	}
	return flag;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
	BOOL flag = NO;
	if (!url)
	{
		return flag;
	}
	NSString *scheme = [url scheme];
	if (scheme && scheme.length > 0)
	{
		SocialService *snsService = [SocialService sharedInstance];
		flag					  = [snsService handleOpenURL:url sourceApplication:nil annotation:nil];
	}
	return flag;
}

//- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler
//{
//    NSString *activityType = userActivity.activityType;
//    if ([NSUserActivityTypeBrowsingWeb  isEqualToString:activityType])
//    {
//        //处理链接页面
//        NSURL *webURL = userActivity.webpageURL;
//        if (webURL && [webURL.host containsString:@""])
//        {
//            //打开对应页面
//        }
//        else
//        {
//            //不能识别则用safari打开
//            [[UIApplication sharedApplication] openURL:webURL];
//        }
//    }
//    return YES;
//}

#pragma mark--------内部方法------------
/**
 *  @author semny
 *
 *  检测广告页面的状态
 *
 *  @return YES:显示广告
 */
- (BOOL)checkADStatus
{
	//是否显示本地广告启动页
	BOOL flag = [KSADMgr checkNeedShowADStartPage];
	return flag;
}

- (BOOL)checkPushADStatus
{
	//是否显示远程广告启动页
	BOOL flag = [KSADMgr checkNeedShowADPushPage];
	return flag;
}

/**
 *  @author semny
 *
 *  设置NUI的配置
 */
- (void)setNUIConfig
{
	//判断屏幕尺寸
	//    CGFloat scale = [UIScreen mainScreen].scale;
	//    int scaleInt = (int)scale;
	//    NSString *nuiStyleStartName = @"KSDefault";
	NSString *nuiStyleName = @"KSDefault.NUI";
	//根据不同的屏幕尺寸加载不同的配置
	//    if (scaleInt > 1 && scaleInt <= 3)
	//    {
	//            //Nx尺寸的UI
	//        nuiStyleName = [NSString stringWithFormat:@"%@@%dx.NUI", nuiStyleStartName,scaleInt];
	//    }

	[NUISettings initWithStylesheet:nuiStyleName];
	if ([NUISettings hasProperty:@"translucent" withClass:@"NavigationBar"])
	{
		[[UINavigationBar appearance] setTranslucent:[NUISettings getBoolean:@"translucent" withClass:@"NavigationBar"]];
	}
	if ([NUISettings hasProperty:@"tint-color" withClass:@"NavigationBar"])
	{
		[[UINavigationBar appearance] setTintColor:[NUISettings getColor:@"tint-color" withClass:@"NavigationBar"]];
	}
}

- (KSMainTabBarVC *)startMainPage
{
	//主Tabbar页
	KSMainTabBarVC *tabbarVC = [self configMainPage];
	//公共参数
	self.window.rootViewController = tabbarVC;
	return tabbarVC;
}

- (KSMainTabBarVC *)configMainPage
{
	//主Tabbar页
	KSMainTabBarVC *tabbarVC = [[KSMainTabBarVC alloc] init];
	tabbarVC.delegate		 = self;
	//公共参数
	self.tabbarVC = tabbarVC;
	return tabbarVC;
}

- (UINavigationController *)configPushADPage
{
	//启动的远程广告页
	KSADPushVC *adVC				  = [[KSADPushVC alloc] init];
	KSAdvertEntity *serverAdForConfig = [KSADMgr getPushADData];
	//判断有没有广告数据
	NSArray *businessData			= nil;
	KSBussinessItemEntity *itemData = nil;
	if (serverAdForConfig && (businessData = serverAdForConfig.businessData) && businessData.count > 0)
	{
		itemData = businessData[0];
	}
	adVC.bitemData				   = itemData;
	UINavigationController *rootVC = [[UINavigationController alloc] initWithRootViewController:adVC];
	return rootVC;
}

- (KSADStartVC *)configStartADPage
{
	//启动的本地广告页
	KSADStartVC *rootVC = [[KSADStartVC alloc] init];
	return rootVC;
}

//配置佳信客服
- (void)configJXCustomerService:(UIApplication *)application launchOptions:(NSDictionary *)launchOptions
{
	NSString *appkey = KJXAppkey; // 此处设置自己的appkey，demo中使用用户输入的key，所以这里为nil
								  //    [sClient clientApplication:application didFinishLaunchingWithOptions:launchOptions
								  //                        appkey:appkey
								  //                  apnsCertName:nil];
	//屏蔽佳信本地推送的消息，包括下线消息、app图标右上角的红色数字等
	JXError *error = [sClient registerSDKWithAppKey:appkey];
	//    if (error) {
	//        [sJXHUD showMessage:[error getLocalDescription] duration:1.4];
	//    }
	//    [[JXLocalPushManager sharedInstance] registerLocalNotification:application];
}

- (void)loginJXCustomer
{
	JXMCSUserManager *mgr = [JXMCSUserManager sharedInstance];
	[mgr
		loginWithAppKey:KJXAppkey
		 responseObject:^(BOOL success, id responseObject) {
			 if (success)
			 {
				 DEBUGG(@"佳信客服登录成功");
			 }
			 else
			 {
				 dispatch_after(
					 dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.f * NSEC_PER_SEC)),
					 dispatch_get_main_queue(), ^{
						 //                                JXError *error = responseObject;
						 //                                [sJXHUD showMessage:[error getLocalDescription] duration:1.f];
					 });
			 }
		 }];
}

//启动图界面
- (void)showLaunchPage
{
	KSLaunchVC *splashVC = [[KSLaunchVC alloc] initWithNibName:@"KSLaunchVC" bundle:nil];
	UIWindow *keywindow  = self.window;
	[keywindow addSubview:splashVC.view];
	[keywindow bringSubviewToFront:splashVC.view];
}

#pragma mark-----安全校验相关界面--------------
//- (KSTouchIdVC*)configTouchIdPage
//{
//    //指纹
//    KSTouchIdVC *touchIdVC = [[KSTouchIdVC alloc] initWithNibName:@"KSTouchIdVC" bundle:nil];
//    @WeakObj(self);
//    touchIdVC.touchIDCheckFinishBlock = ^(UIViewController *vc, NSInteger actionType,  NSError *error){
//        if (error)
//        {
//            //验证错误
//        }
//        else
//        {
//            //验证完成后,直接跳转到主页
//            [weakself startMainPage];
//        }
//    };
//    return touchIdVC;
//}
//
//- (UINavigationController*)configGestureSettingPage
//{
//    //手势设置
//    KSGestureSettingVC *settingVC = [[KSGestureSettingVC alloc] initWithNibName:@"KSGestureSettingVC" bundle:nil];
//    settingVC.fromType = GestureFromTypeInStart;
//    @WeakObj(self);
//    //设置页面操作回调
//    settingVC.gestureSettingFinishBlock = ^(UIViewController *vc, NSInteger actionType, NSError *error){
//        if (actionType == GestureActionTypeCompleted || actionType == GestureActionTypeJump)
//        {
//            if (error)
//            {
//                //报错，不需要做任何处理
//                return;
//            }
//            //完成设置
//            //跳转主页面
//            [weakself startMainPage];
//        }
//        else
//        {
//            //回退返回处理
//            //取消设置
//            [vc dismissViewControllerAnimated:YES completion:nil];
//        }
//    };
//    UINavigationController *rootVC = [[UINavigationController alloc] initWithRootViewController:settingVC];
//    return rootVC;
//}
//
//- (UINavigationController*)configGestureVerifyPage
//{
//    //手势校验
//    KSGestureVerifyVC *verifyVC = [[KSGestureVerifyVC alloc] initWithNibName:@"KSGestureVerifyVC" bundle:nil];
//    verifyVC.fromType = GestureFromTypeInStart;
//    @WeakObj(self);
//    //设置页面操作回调
//    verifyVC.gestureVerifyFinishBlock = ^(UIViewController *vc, NSInteger actionType, NSError *error){
//        if (actionType == GestureActionTypeCompleted || actionType == GestureActionTypeJump)
//        {
//            //完成设置
//            if (error)
//            {
//                //报错，判断错误类型
//                NSInteger errorCode = error.code;
//                if(errorCode == KGestureVerifyErrorCode)
//                {
//                    //跳转登录
//                    [weakself turn2LoginPage];
//                }
//            }
//            else
//            {
//                //跳转主页面
//                [weakself startMainPage];
//            }
//        }
//        else
//        {
//            //回退返回处理
//            //取消设置
//            [vc dismissViewControllerAnimated:YES completion:nil];
//        }
//    };
//    UINavigationController *rootVC = [[UINavigationController alloc] initWithRootViewController:verifyVC];
//    return rootVC;
//}

- (void)turn2LoginPage
{
	//清理掉登录态
	[USER_MGR clearOwner];
	//切换root
	[self startMainPage];
	//跳转登录界面
	[USER_MGR judgeLoginForVC:self.tabbarVC needEndAnimation:YES];
}

#pragma mark-------校验相关-----
////校验相关的界面启动
//- (UIViewController*)startSecurityPageWith:(void (^)(UIViewController*vc))beginStart
//{
//    SQTouchLockMgr *touchLockMgr = [SQTouchLockMgr sharedInstance];
//    //判断是否支持
//    BOOL flag = [touchLockMgr isAuthenticationEnabledForDefaultFeatureAndLogin];
//    //判断手势密码
//    GestureType type = [SQGestureMgr checkAuthenticationTypeByGestureAndLogin];
//
//    UIViewController *rootVC = nil;
//    if (flag && !TARGET_IPHONE_SIMULATOR)
//    {
//        //支持指纹密码并且登录了跳转校验
//        //主Tabbar页
//        rootVC = [self configTouchIdPage];
//    }
//    else if (type == GestureTypeSetting)
//    {
//        //如果是需要设置手势密码
//        rootVC = [self configGestureSettingPage];
//    }
//    else if (type == GestureTypeLogin)
//    {
//        //手势密码校验
//        rootVC = [self configGestureVerifyPage];
//    }
//    else
//    {
//        //暂无校验页面跳转
//    }
//
//    if (rootVC && [rootVC isKindOfClass:[UIViewController class]])
//    {
//        if (beginStart)
//        {
//            beginStart(rootVC);
//        }
//        //公共参数
//        self.window.rootViewController = rootVC;
//    }
//    else
//    {
//        rootVC = nil;
//    }
//    return rootVC;
//}

#pragma mark-----安全校验相关界面--------------
- (UIViewController *)configSecurityPageWithNeedStartMain:(BOOL)needStartMain afterBlock:(void (^)(UIViewController *vc))afterBlock
{
	SQTouchLockMgr *touchLockMgr = [SQTouchLockMgr sharedInstance];
	//判断是否支持
	BOOL flag = [touchLockMgr isAuthenticationEnabledForDefaultFeatureAndLogin];
	//判断手势密码
	GestureType type = [SQGestureMgr checkAuthenticationTypeByGestureAndLogin];

	UIViewController *rootVC = nil;
	if (flag && !TARGET_IPHONE_SIMULATOR)
	{
		//支持指纹密码并且登录了跳转校验
		//主Tabbar页
		rootVC = [self configTouchIdPageWithAfter:afterBlock];
	}
	else if (type == GestureTypeSetting)
	{
		//如果是需要设置手势密码
		rootVC = [self configGestureSettingPageWithAfter:afterBlock];
	}
	else if (type == GestureTypeLogin)
	{
		//手势密码校验
		rootVC = [self configGestureVerifyPageWithAfter:afterBlock];
	}
	else
	{
		//不支持就直接跳转主页面
		if (needStartMain)
		{
			//主Tabbar页
			rootVC = [self configMainPage];
		}
	}
	return rootVC;
}

//校验相关的界面启动
- (UIViewController *)startSecurityPageWithBegin:(void (^)(UIViewController *vc))beginStart afterBlock:(void (^)(UIViewController *vc))afterBlock
{
	UIViewController *rootVC = nil;
	rootVC					 = [self configSecurityPageWithNeedStartMain:NO afterBlock:afterBlock];
	//开始启动前block
	if (beginStart)
	{
		beginStart(rootVC);
	}
	if (rootVC && [rootVC isKindOfClass:[UIViewController class]])
	{
		//公共参数
		self.window.rootViewController = rootVC;
	}
	else
	{
		rootVC = nil;
	}
	return rootVC;
}

- (KSTouchIdVC *)configTouchIdPageWithAfter:(void (^)(UIViewController *vc))afterBlock
{
	//指纹
	KSTouchIdVC *touchIdVC = [[KSTouchIdVC alloc] initWithNibName:@"KSTouchIdVC" bundle:nil];
	@WeakObj(self);
	touchIdVC.touchIDCheckFinishBlock = ^(UIViewController *vc, NSInteger actionType, NSError *error) {
		if (error)
		{
			//验证错误
		}
		else
		{
			//验证完成后,直接跳转到主页
			[weakself startMainPage];
			if (afterBlock)
			{
				afterBlock(vc);
			}
		}
	};
	return touchIdVC;
}

- (UINavigationController *)configGestureSettingPageWithAfter:(void (^)(UIViewController *vc))afterBlock
{
	//手势设置
	KSGestureSettingVC *settingVC = [[KSGestureSettingVC alloc] initWithNibName:@"KSGestureSettingVC" bundle:nil];
	settingVC.fromType			  = GestureFromTypeInStart;
	@WeakObj(self);
	//设置页面操作回调
	settingVC.gestureSettingFinishBlock = ^(UIViewController *vc, NSInteger actionType, NSError *error) {
		if (actionType == GestureActionTypeCompleted || actionType == GestureActionTypeJump)
		{
			if (error)
			{
				//报错，不需要做任何处理
				return;
			}
			//完成设置
			//跳转主页面
			[weakself startMainPage];
			if (afterBlock)
			{
				afterBlock(vc);
			}
		}
		else
		{
			//回退返回处理
			//取消设置
			[vc dismissViewControllerAnimated:YES completion:nil];
		}
	};
	UINavigationController *rootVC = [[UINavigationController alloc] initWithRootViewController:settingVC];
	return rootVC;
}

- (UINavigationController *)configGestureVerifyPageWithAfter:(void (^)(UIViewController *vc))afterBlock
{
	//手势校验
	KSGestureVerifyVC *verifyVC = [[KSGestureVerifyVC alloc] initWithNibName:@"KSGestureVerifyVC" bundle:nil];
	verifyVC.fromType			= GestureFromTypeInStart;
	@WeakObj(self);
	//设置页面操作回调
	verifyVC.gestureVerifyFinishBlock = ^(UIViewController *vc, NSInteger actionType, NSError *error) {
		if (actionType == GestureActionTypeCompleted || actionType == GestureActionTypeJump)
		{
			//完成设置
			if (error)
			{
				//报错，判断错误类型
				NSInteger errorCode = error.code;
				if (errorCode == KGestureVerifyErrorCode)
				{
					//跳转登录
					[weakself turn2LoginPage];
				}
			}
			else
			{
				//跳转主页面
				[weakself startMainPage];
				if (afterBlock)
				{
					afterBlock(vc);
				}
			}
		}
		else
		{
			//回退返回处理
			//取消设置
			[vc dismissViewControllerAnimated:YES completion:nil];
		}
	};
	UINavigationController *rootVC = [[UINavigationController alloc] initWithRootViewController:verifyVC];
	return rootVC;
}

#pragma mark - 登录态的改变
- (void)loginStatusChanged:(NSNotification *)notify
{
	DEBUGG(@"%s notify:%@", __FUNCTION__, notify);
	//目前暂用于  注销登录
	NSDictionary *loginStateDic = notify.object;
	BOOL loginStatus			= YES;
	//int loginPath = LoginPathInProcess;
	int loginType = LoginTypeByLogin;
	if (loginStateDic && [loginStateDic count] > 0)
	{
		//状态
		NSNumber *loginState = [loginStateDic objectForKey:KLoginStatus];
		loginStatus			 = loginState.boolValue;
		//路径
		//NSNumber *loginPathNum = [loginStateDic objectForKey:KLoginPathInAction];
		//loginPath = loginPathNum.intValue;
		//登录的类型
		NSNumber *loginTypeNum = [loginStateDic objectForKey:KLoginTypeInAction];
		loginType			   = loginTypeNum.intValue;
	}
	else
	{
		return;
	}

	if (loginStatus)
	{
		if (loginType == LoginTypeByRegister)
		{
			//注册成功的流程有结果页面,不能小视
		}
		else
		{
			// 登录，直接进
			[USER_MGR dismissLoginProgressFor:self.tabbarVC completion:nil];
		}
	}
	else
	{
		//清理登录态
		[USER_MGR clearOwner];
		[USER_MGR judgeLoginForVC:self.tabbarVC];
	}
}

#pragma mark -
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
	UIViewController *sVC = tabBarController.selectedViewController;
	if ([sVC isEqual:viewController])
	{
		return NO;
	}
	else
	{
		NSArray *vcs	= tabBarController.viewControllers;
		NSInteger index = -1;
		if (vcs && vcs.count > 0)
		{
			index = [vcs indexOfObject:viewController];
		}

		switch (index)
		{
			case 0:
				//首页
				break;
			case 1:
				//投资理财
				break;
			case 2:
			{
				//个人中心,可以先弹登录
				//                UIViewController *preVC = tabBarController.selectedViewController;
				//                BOOL flag = [USER_MGR judgeLoginForVC:preVC];
				//                if (!flag)
				//                {
				//                    return NO;
				//                }
			}
			break;
			default:
				break;
		}

		//回退到首页
		UINavigationController *nav = nil;
		if ([viewController isKindOfClass:[UINavigationController class]])
		{
			nav = (UINavigationController *)viewController;
		}
		[nav popToRootViewControllerAnimated:YES];
	}

	return YES;
}

@end
