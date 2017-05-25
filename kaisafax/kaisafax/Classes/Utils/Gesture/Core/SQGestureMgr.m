//
//  SQGestureMgr.m
//  kaisafax
//
//  Created by semny on 16/11/16.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "SQGestureMgr.h"
#import "KSUserMgr.h"
#import "KSKeychain.h"

//手势密码设置是否跳过的标志key
static NSString *const KGestureJumpedFlagKey = @"GestureJumpedFlagKey";
static NSString *const KGestureSettedFlagKey = @"GestureSettedFlagKey";

@implementation SQGestureMgr
/**
 *  @author semny
 *
 *  初始化手势管理工具
 *
 *  @return 手势管理工具单例对象
 */
+ (SQGestureMgr *)sharedInstance
{
    static SQGestureMgr *obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[SQGestureMgr alloc] init];
    });
    
    return obj;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
    }
    return self;
}

//判断是否支持手势密码及密码类型
+ (GestureType)checkAuthenticationTypeByGestureAndLogin
{
    GestureType type = GestureTypeUnknown;
    BOOL isLogin = [[KSUserMgr sharedInstance] isLogin];
    if (!isLogin)
    {
        return type;
    }
    
    long long account = [KSUserMgr sharedInstance].user.user.userId;
    NSString *accountStr = nil;
    if (account > 0)
    {
        accountStr = [NSString stringWithFormat:@"%lld", account];
    }
    return [self checkAuthenticationTypeByGestureWith:accountStr];
}

//判断featureName的功能名称下 touchID是否有效 是否开启开关
+ (GestureType)checkAuthenticationTypeByGestureWith:(NSString*)account
{
    //是否开启了手势锁
    GestureType type = GestureTypeUnknown;
    if (!account || account.length <= 0)
    {
        return type;
    }
    
    //检测是否设置了手势锁
    NSString *gesture = [SQGestureMgr getGestureWithKey:account];
    if (gesture && gesture.length > 0)
    {
        type = GestureTypeLogin;
        //设置了手势锁
        return type;
    }
    
    //检查是否设置过
    BOOL isSetted = [SQGestureMgr loadIsGestureSettedForAccount:account];
    if (isSetted)
    {
        //已经设置过，表示可能已近关闭了
        return type;
    }
    
    //检测是否跳过的标志
    BOOL isJumped = [SQGestureMgr loadIsGestureJumpedForAccount:account];
    if (!isJumped)
    {
        type = GestureTypeSetting;
    }
    return type;
}

//校验手势密码是否和设置的一致
+ (BOOL)checkInputGestureForDefaultAccount:(NSString *)gesture
{
    BOOL isLogin = [[KSUserMgr sharedInstance] isLogin];
    if (!isLogin || !gesture || gesture.length <= 0)
    {
        return NO;
    }
    long long account = USER_MGR.user.user.userId;
    NSString *accountStr = nil;
    if (account > 0)
    {
        accountStr = [NSString stringWithFormat:@"%lld", account];
    }
    NSString *settedGesture = [self getGestureWithKey:accountStr];
    if ([gesture isEqualToString:settedGesture])
    {
        return YES;
    }
    return NO;
}

//设置默认账户下的手势密码
+ (void)setGestureForDefaultAccount:(NSString *)gesture
{
    BOOL isLogin = [[KSUserMgr sharedInstance] isLogin];
    if (!isLogin || !gesture || gesture.length <= 0)
    {
        return;
    }
    long long account = USER_MGR.user.user.userId;
    NSString *accountStr = nil;
    if (account > 0)
    {
        accountStr = [NSString stringWithFormat:@"%lld", account];
    }
    BOOL flag = [self saveGesture:gesture key:accountStr];
    if (flag)
    {
        [self setIsGestureSetted:YES forAccount:accountStr];
    }
}

//删除默认模式下的手势密码
+ (BOOL)deleteGestureForDefaultAccount
{
    BOOL isLogin = [[KSUserMgr sharedInstance] isLogin];
    if (!isLogin)
    {
        return NO;
    }
    long long account = USER_MGR.user.user.userId;
    NSString *accountStr = nil;
    if (account > 0)
    {
        accountStr = [NSString stringWithFormat:@"%lld", account];
    }
    return [self deleteGestureWithKey:accountStr];
}

//删除默认模式下的手势密码
+ (NSString *)getGestureForDefaultAccount
{
    BOOL isLogin = [[KSUserMgr sharedInstance] isLogin];
    if (!isLogin)
    {
        return nil;
    }
    long long account = USER_MGR.user.user.userId;
    NSString *accountStr = nil;
    if (account > 0)
    {
        accountStr = [NSString stringWithFormat:@"%lld", account];
    }
    return [self getGestureWithKey:accountStr];
}

+ (void)setIsGestureJumpedForDefaultAccount:(BOOL)isJumped
{
    BOOL isLogin = [[KSUserMgr sharedInstance] isLogin];
    if (!isLogin)
    {
        return;
    }
    long long account = USER_MGR.user.user.userId;
    NSString *accountStr = nil;
    if (account > 0)
    {
        accountStr = [NSString stringWithFormat:@"%lld", account];
    }
    return [self setIsGestureJumped:isJumped forAccount:accountStr];
}

//存储设置过的标志
+ (void)setIsGestureSettedForDefaultAccount:(BOOL)isSetted
{
    BOOL isLogin = [[KSUserMgr sharedInstance] isLogin];
    if (!isLogin)
    {
        return;
    }
    long long account = USER_MGR.user.user.userId;
    NSString *accountStr = nil;
    if (account > 0)
    {
        accountStr = [NSString stringWithFormat:@"%lld", account];
    }
    return [self setIsGestureSetted:isSetted forAccount:accountStr];
}

#pragma mark -------存储获取(私有)-------------
+ (BOOL)saveGesture:(NSString *)gesture key:(NSString *)key
{
    return [KSKeychain setGesture:gesture account:key];
}

+ (NSString *)getGestureWithKey:(NSString *)key
{
    NSString *gesture = [KSKeychain gestureForAccount:key];
    return gesture;
}

+ (BOOL)deleteGestureWithKey:(NSString *)key
{
    return [KSKeychain deleteGestureForAccount:key];
}

#pragma mark -------存储跳转标志-------------
+ (void)setIsGestureJumped:(BOOL)isJumped forAccount:(NSString *)account
{
    if (!account || account.length <= 0)
    {
        return;
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *featuresDictionary = nil;
    NSDictionary *currentDictionary = [userDefaults valueForKey:account];
    if (currentDictionary == nil) {
        featuresDictionary = [NSMutableDictionary dictionary];
    } else {
        featuresDictionary = [NSMutableDictionary dictionaryWithDictionary:currentDictionary];
    }
    
    [featuresDictionary setValue:@(isJumped) forKey:KGestureJumpedFlagKey];
    [userDefaults setValue:featuresDictionary forKey:account];
    [userDefaults synchronize];
}

+ (BOOL)loadIsGestureJumpedForAccount:(NSString *)account
{
    if (!account || account.length <= 0)
    {
        return NO;
    }
    NSDictionary *featuresDictionary = [[NSUserDefaults standardUserDefaults] valueForKey:account];
    return [[featuresDictionary valueForKey:KGestureJumpedFlagKey] boolValue];;
}

+ (void)setIsGestureSetted:(BOOL)isSetted forAccount:(NSString *)account
{
    if (!account || account.length <= 0)
    {
        return;
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *featuresDictionary = nil;
    NSDictionary *currentDictionary = [userDefaults valueForKey:account];
    if (currentDictionary == nil) {
        featuresDictionary = [NSMutableDictionary dictionary];
    } else {
        featuresDictionary = [NSMutableDictionary dictionaryWithDictionary:currentDictionary];
    }
    
    [featuresDictionary setValue:@(isSetted) forKey:KGestureSettedFlagKey];
    [userDefaults setValue:featuresDictionary forKey:account];
    [userDefaults synchronize];
}

+ (BOOL)loadIsGestureSettedForAccount:(NSString *)account
{
    if (!account || account.length <= 0)
    {
        return NO;
    }
    NSDictionary *featuresDictionary = [[NSUserDefaults standardUserDefaults] valueForKey:account];
    return [[featuresDictionary valueForKey:KGestureSettedFlagKey] boolValue];;
}
@end
