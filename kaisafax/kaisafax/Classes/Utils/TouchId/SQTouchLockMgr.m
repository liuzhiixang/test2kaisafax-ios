//
//  SQTouchLockMgr.m
//  kaisafax
//
//  Created by semny on 16/11/10.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "SQTouchLockMgr.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "KSUserMgr.h"

//系统版本
#define TL_SystemVersion ([UIDevice currentDevice].systemVersion.floatValue)
#define TL_IOS8_AND_LATER (TL_SystemVersion >= 8.0)
#define TL_IOS9_AND_LATER (TL_SystemVersion >= 9.0)
#define TL_IOS10_AND_LATER (TL_SystemVersion >= 10.0)

//最大验证失败次数
#define KTLMaxBiometryFailures 5

static NSString *const KTouchLockUserDefaultsKeyTouchIDActivated = @"TouchLockUserDefaultsKeyTouchIDActivated";

static NSString *const KBiometricAuthenticationFacadeVersion = @"1.0.4";
static NSString *const KBiometricsErrorDomain = @"BiometricsAuthenticationDomain";
//标志的缓存信息key
static NSString *const KFeaturesDictionaryKey = @"FeaturesDictionaryKey";
static NSString *const KFeatureNameForAppLock = @"FeatureNameForAppLock";

@interface SQTouchLockMgr()

//安全验证对象
//@property (nonatomic, strong) LAContext *authenticationContext;
//显示密码界面的标志
@property (nonatomic, assign) BOOL touchIDCancelPresentsPasscodeViewController;

@end

@implementation SQTouchLockMgr

/**
 *  @author semny
 *
 *  初始化Touch id管理工具
 *
 *  @return Touch id管理工具单例对象
 */
+ (SQTouchLockMgr *)sharedInstance
{
    static SQTouchLockMgr *obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[SQTouchLockMgr alloc] init];
    });
    
    return obj;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        //创建安全验证对象
        if (TL_IOS8_AND_LATER)
        {
            //指纹验证失败次数超限后是否自动校验密码(默认校验)
            _needPasswordForMaxBiometryFailed = YES;
            _needCheckBiometryAfterPasscode = YES;
            
            //默认fallbacktitle为空串,去掉指纹输错后的右边按钮显示(nil的时候显示默认的文字)
            _fallbackTitle = @"";
        }
    }
    return self;
}

- (LAContext*)configAuthenticationContext
{
    //初始化
    LAContext *authenticationContext = [[LAContext alloc] init];
    //指纹最大验证失败次数设置为5，默认为3次
    if ([authenticationContext respondsToSelector:@selector(maxBiometryFailures)]) {
        authenticationContext.maxBiometryFailures = @(KTLMaxBiometryFailures);
    }
    return authenticationContext;
}

#pragma mark - 工具方法
//判断是否支持touch id
- (BOOL)isSupportTouchID
{
    NSError *error = nil;
    BOOL isSupport = [self isAuthenticationEnabledByBiometricsWithError:&error];
    if (!isSupport)
    {
        NSInteger errorCode = error.code;
        //不支持的设备
        if (errorCode == LAErrorTouchIDNotAvailable)
        {
            return NO;
        }
    }
    //此处默认使用指纹验证
    return YES;
}

//判断touch id是否有效
- (BOOL)isAuthenticationEnabledByBiometrics
{
    //此处默认使用指纹验证
    return [self isAuthenticationEnabledByBiometricsWithError:nil];
}

//判断是否touch id可用
- (BOOL)isAuthenticationEnabledByBiometricsWithError:(NSError * __autoreleasing *)error
{
    /**
     *LAPolicyDeviceOwnerAuthentication 手机密码的验证方式
     *LAPolicyDeviceOwnerAuthenticationWithBiometrics 指纹的验证方式
     */
    //IOS8以后才支持
    if (!TL_IOS8_AND_LATER)
    {
        return NO;
    }
    //判断是否支持密码验证
    LAContext *authenticationContext = [self configAuthenticationContext];
    //此处默认使用指纹验证
    LAPolicy policy = LAPolicyDeviceOwnerAuthenticationWithBiometrics;
    BOOL can = NO;
    if (authenticationContext)
    {
        can = [authenticationContext canEvaluatePolicy:policy error:error];
    }
    return can;
}

//判断featureName的功能名称下 touchID是否有效 是否开启开关 error处理
- (BOOL)isAuthenticationEnabledForFeature:(NSString *)featureName error:(NSError * __autoreleasing *)error
{
    return [self isAuthenticationEnabledByBiometricsWithError:error] && [self loadIsAuthenticationEnabledForFeature:featureName];
}

//判断featureName的功能名称下 touchID是否有效 是否开启开关
- (BOOL)isAuthenticationEnabledForFeature:(NSString *)featureName
{
    return [self isAuthenticationEnabledForFeature:featureName error:nil];
}

//判断默认的功能名称下 touchID是否有效 是否开启开关
- (BOOL)isAuthenticationEnabledForDefaultFeatureWithError:(NSError * __autoreleasing *)error
{
    NSString *featureName = KFeatureNameForAppLock;
    return [self isAuthenticationEnabledForFeature:featureName error:error];
}

//判断默认的功能名称下 touchID是否有效 是否开启开关 登录
- (BOOL)isAuthenticationEnabledForDefaultFeatureAndLogin
{
    BOOL isLogin = [[KSUserMgr sharedInstance] isLogin];
    return isLogin && [self isAuthenticationEnabledForDefaultFeature];
}

//判断默认的功能名称下 touchID是否有效 是否开启开关
- (BOOL)isAuthenticationEnabledForDefaultFeature
{
    NSString *featureName = KFeatureNameForAppLock;
    return [self isAuthenticationEnabledForFeature:featureName];
}

#pragma mark ------操作touchid验证-------------
//开启指纹校验开关
- (void)enableAuthenticationForAccount:(NSString*)account succesBlock:(void(^)(SQTouchLockPolicy policy))successBlock failureBlock:(void(^)(NSError *error))failureBlock
{
    //默认是app锁屏功能名称
    NSString *featureName = KFeatureNameForAppLock;
    [self enableAuthenticationForFeature:featureName account:account succesBlock:successBlock failureBlock:failureBlock];
}

//开启指纹校验开关
- (void)enableAuthenticationForFeature:(NSString *)featureName account:(NSString*)account succesBlock:(void(^)(SQTouchLockPolicy policy))successBlock failureBlock:(void(^)(NSError *error))failureBlock
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSError *error = nil;
        NSInteger APolicy = SQTouchLockPolicyAuthenticationWithBiometrics;
        //判断是否支持指纹校验
        if ([self isAuthenticationEnabledByBiometricsWithError:&error])
        {
            if ([self isAuthenticationEnabledForFeature:featureName])
            {
                //标志已经开启直接回调
                if (successBlock)
                {
                    successBlock(APolicy);
                }
            }
            else
            {
                //设置标志
                [self setAuthenticationEnabled:YES forFeature:featureName account:account];
                if (successBlock)
                {
                    successBlock(APolicy);
                }
            }
        }
        else
        {
            //不支持指纹校验 直接错误回调
            if (!error)
            {
                error = self.authenticationUnavailabilityError;
            }
            if (failureBlock)
            {
                failureBlock(error);
            }
        }
    });
}

//关闭指纹校验开关
- (void)disableAuthenticationWithReason:(NSString *)reason succesBlock:(void(^)(SQTouchLockPolicy policy))successBlock failureBlock:(void(^)(NSError *error))failureBlock
{
    //默认是app锁屏功能名称
    NSString *featureName = KFeatureNameForAppLock;
    [self disableAuthenticationForFeature:featureName reason:reason succesBlock:successBlock failureBlock:failureBlock];
}

//关闭指纹校验开关
- (void)disableAuthenticationForFeature:(NSString *)featureName reason:(NSString *)reason succesBlock:(void(^)(SQTouchLockPolicy policy))successBlock failureBlock:(void(^)(NSError *error))failureBlock
{
    [self authenticateForAccessToFeature:featureName reason:reason succesBlock:successBlock failureBlock:failureBlock];
}

//优先判断是否可用和开关
- (void)authenticateForAccessAndSwitchWithReason:(NSString *)reason succesBlock:(void(^)(SQTouchLockPolicy policy))successBlock failureBlock:(void(^)(NSError *error))failureBlock
{
    //默认是app锁屏功能名称
    NSString *featureName = KFeatureNameForAppLock;
    [self authenticateForAccessAndSwitchToFeature:featureName reason:reason succesBlock:successBlock failureBlock:failureBlock];
}

//校验开关是否打开
- (void)authenticateForAccessAndSwitchToFeature:(NSString *)featureName reason:(NSString *)reason succesBlock:(void(^)(SQTouchLockPolicy policy))successBlock failureBlock:(void(^)(NSError *error))failureBlock
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSError *error = nil;
        NSInteger APolicy = SQTouchLockPolicyAuthenticationWithBiometrics;
        //判断是否支持指纹校验
        if ([self isAuthenticationEnabledByBiometricsWithError:&error])
        {
            if ([self isAuthenticationEnabledForFeature:featureName])
            {
                [self checkBiometricsWithReason:reason succesBlock:successBlock failureBlock:failureBlock];
            }
            else
            {
                //没有打开校验指纹的开关，直接回调成功
                if (successBlock)
                {
                    successBlock(APolicy);
                }
            }
        }
        else
        {
            DEBUGG(@"111 %s %@", __FUNCTION__, error);
            //不支持指纹校验 直接错误回调
            if (!error)
            {
                error = self.authenticationUnavailabilityError;
            }
            else
            {
                //特殊错误处理
                NSInteger errorCode = error.code;
                //多次输入出错
                if((errorCode == LAErrorTouchIDLockout /*|| errorCode == LAErrorAuthenticationFailed*/) && self.needPasswordForMaxBiometryFailed)
                {
                    DEBUGG(@"222 %s %@", __FUNCTION__, error);
                    [self checkPasswordInBiometricsWithReason:reason succesBlock:successBlock failureBlock:failureBlock];
                    return;
                }
            }
            DEBUGG(@"333 %s %@", __FUNCTION__, error);
            if (failureBlock)
            {
                failureBlock(error);
            }
        }
    });
}

- (void)authenticateForAccessWithReason:(NSString *)reason succesBlock:(void(^)(SQTouchLockPolicy policy))successBlock failureBlock:(void(^)(NSError *error))failureBlock
{
    //默认是app锁屏功能名称
    NSString *featureName = KFeatureNameForAppLock;
    [self authenticateForAccessToFeature:featureName reason:reason succesBlock:successBlock failureBlock:failureBlock];
}

//只检测是否支持， 并且打开指纹
- (void)authenticateForAccessToFeature:(NSString *)featureName reason:(NSString *)reason succesBlock:(void(^)(SQTouchLockPolicy policy))successBlock failureBlock:(void(^)(NSError *error))failureBlock
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSError *tempError = nil;
        //判断是否支持指纹校验
        if ([self isAuthenticationEnabledByBiometricsWithError:&tempError])
        {
            [self checkBiometricsWithReason:reason succesBlock:successBlock failureBlock:failureBlock];
        }
        else
        {
            DEBUGG(@"111 %s %@", __FUNCTION__, tempError);
            //不支持指纹校验 直接错误回调
            if (!tempError)
            {
                tempError = self.authenticationUnavailabilityError;
            }
            else
            {
                //特殊错误处理
                NSInteger errorCode = tempError.code;
                //多次输入出错
                if((errorCode == LAErrorTouchIDLockout /* || errorCode == LAErrorAuthenticationFailed*/) && self.needPasswordForMaxBiometryFailed)
                {
                    DEBUGG(@"222 %s %@", __FUNCTION__, tempError);
                    [self checkPasswordInBiometricsWithReason:reason succesBlock:successBlock failureBlock:failureBlock];
                    return;
                }
            }
            DEBUGG(@"333 %s %@", __FUNCTION__, tempError);
            if (failureBlock)
            {
                failureBlock(tempError);
            }
        }
    });
}

//默认的fallbackTitle和cancelTitle,以及默认使用指纹校验
- (void)checkBiometricsWithReason:(NSString*)reason succesBlock:(void(^)(SQTouchLockPolicy policy))successBlock failureBlock:(void(^)(NSError *error))failureBlock
{
    NSInteger policy = SQTouchLockPolicyAuthenticationWithBiometrics;
    NSString *fallbackTitle = _fallbackTitle;
    NSString *cancelTitle = _cancelTitle;
    @WeakObj(self);
    [self checkWithPolicy:policy reason:reason fallbackTitle:fallbackTitle cancelTitle:cancelTitle succesBlock:^(SQTouchLockPolicy policy) {
        DEBUGG(@"111 %s %d", __FUNCTION__, (int)policy);
        //判断是否为密码解锁，并且是否需要重新验证指纹
        if (policy == LAPolicyDeviceOwnerAuthentication && weakself.needCheckBiometryAfterPasscode)
        {
            [weakself checkBiometricsWithReason:reason succesBlock:successBlock failureBlock:failureBlock];
            return;
        }
        DEBUGG(@"222 %s %d", __FUNCTION__, (int)policy);
        //其他情况直接成功回调
        if (successBlock)
        {
            successBlock(policy);
        }
    } failureBlock:failureBlock];
}

//默认的fallbackTitle和cancelTitle,以及默认使用密码校验
- (void)checkPasswordWithReason:(NSString*)reason succesBlock:(void(^)(SQTouchLockPolicy policy))successBlock failureBlock:(void(^)(NSError *error))failureBlock
{
    NSInteger policy = SQTouchLockPolicyAuthentication;
    NSString *fallbackTitle = _fallbackTitle;
    NSString *cancelTitle = _cancelTitle;
    [self checkWithPolicy:policy reason:reason fallbackTitle:fallbackTitle cancelTitle:cancelTitle succesBlock:successBlock failureBlock:failureBlock];
}

//默认的fallbackTitle和cancelTitle,在指纹校验中使用密码校验
- (void)checkPasswordInBiometricsWithReason:(NSString*)reason succesBlock:(void(^)(SQTouchLockPolicy policy))successBlock failureBlock:(void(^)(NSError *error))failureBlock
{
    NSInteger policy = SQTouchLockPolicyAuthentication;
    NSString *fallbackTitle = _fallbackTitle;
    NSString *cancelTitle = _cancelTitle;
    @WeakObj(self);
    [self checkWithPolicy:policy reason:reason fallbackTitle:fallbackTitle cancelTitle:cancelTitle succesBlock:^(SQTouchLockPolicy policy) {
        DEBUGG(@"111 %s %d", __FUNCTION__, (int)policy);
        //判断是否为密码解锁，并且是否需要重新验证指纹
        if (policy == LAPolicyDeviceOwnerAuthentication && weakself.needCheckBiometryAfterPasscode)
        {
            [weakself checkBiometricsWithReason:reason succesBlock:successBlock failureBlock:failureBlock];
            return;
        }
        DEBUGG(@"222 %s %d", __FUNCTION__, (int)policy);
        //其他情况直接成功回调
        if (successBlock)
        {
            successBlock(policy);
        }
    } failureBlock:failureBlock];
}

/**
1.在 iPhone5 上的时候,LAContext *authenticationContext = [[LAContext alloc] init]; 初始化的对象为 nil。
2.在5s 上没有设置指纹密码时, error = -7 (LAErrorTouchIDNotEnrolled)。
3.输入错误指纹时.若一共有三次机会,三次全部错误后, error = -1 (LAErrorAuthenticationFailed)
4.authenticationContext .localizedFallbackTitle，修改指纹验证弹框右侧输入密码按钮文案属性。
5.authenticationContext .localizedCancelTitle，修改指纹验证弹框左侧取消按钮文案属性。
6.authenticationContext .maxBiometryFailures，修改指纹验证最大次数属性。
7.认证失败错误类型7，8，9三项是iOS9加入的三种新错误类型。
*/
- (void)checkWithPolicy:(SQTouchLockPolicy)policy reason:(NSString*)reason fallbackTitle:(NSString*)fallbackTitle cancelTitle:(NSString*)cancelTitle succesBlock:(void(^)(SQTouchLockPolicy policy))successBlock failureBlock:(void(^)(NSError *error))failureBlock
{
    //判断是否支持密码验证
    LAContext *authenticationContext = [self configAuthenticationContext];
    if(!authenticationContext)
    {
        //无法正常创建context,说明设备不支持
        NSError *tempError = self.authenticationUnSupportError;
        if (failureBlock)
        {
            failureBlock(tempError);
        }
        return;
    }
    
    //支持的话，继续监测
    static BOOL isTouchIDPresented = NO;
    //其他操作的title
    NSString *fallbackTitleStr = fallbackTitle;
    authenticationContext.localizedFallbackTitle = fallbackTitleStr;
    
    //iOS10以后才可以设置取消操作的title
    if (TL_IOS10_AND_LATER)
    {
        NSString *cancelTitleStr = cancelTitle;
        if (cancelTitleStr.length <= 0)
        {
            cancelTitleStr = nil;
        }
        authenticationContext.localizedCancelTitle = cancelTitleStr;
    }
    
    //验证使用的类型(指纹，数字密码)
    NSInteger APolicy = policy;
    if (!TL_IOS9_AND_LATER)
    {
        APolicy = LAPolicyDeviceOwnerAuthenticationWithBiometrics;
    }
    else
    {
        APolicy = policy;
    }
    
    if (!isTouchIDPresented)
    {
        isTouchIDPresented = YES;
        @WeakObj(self);
        [authenticationContext evaluatePolicy:APolicy localizedReason:reason reply:^(BOOL success, NSError *error){
            isTouchIDPresented = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success)
                {
                    DEBUGG(@"111 %s %@", __FUNCTION__, error);
                    if (successBlock)
                    {
                        successBlock(APolicy);
                    }
                }
                else
                {
                    //特殊错误处理
                    NSInteger errorCode = error.code;
                    DEBUGG(@"111 %s %@", __FUNCTION__, error);
                    //多次输入出错
                    if((errorCode == LAErrorTouchIDLockout || errorCode == LAErrorAuthenticationFailed) && weakself.needPasswordForMaxBiometryFailed)
                    {
                        DEBUGG(@"222 %s %@", __FUNCTION__, error);
//                        [self checkPasswordWithReason:reason succesBlock:successBlock failureBlock:failureBlock];
//                        return;
                    }
                    DEBUGG(@"333 %s %@", __FUNCTION__, error);
                    if (failureBlock)
                    {
                        failureBlock(error);
                    }
                }
            });
        }];
    }
    else
    {
        if (failureBlock)
        {
            failureBlock(self.authenticationAlreadyPresentError);
        }
    }
}

#pragma mark ------错误描述-----------
//错误描述
- (NSString *)getAuthErrorDescription:(NSInteger)code
{
    NSString *msg = nil;
    switch (code)
    {
        case LAErrorTouchIDNotEnrolled:
            //认证不能开始,因为touch id没有录入指纹.
            msg = @"此设备未录入指纹信息!";
            break;
        case LAErrorTouchIDNotAvailable:
            //认证不能开始,因为touch id在此台设备尚是无效的.
            msg = @"此设备不支持Touch ID!";
            break;
        case LAErrorPasscodeNotSet:
            //认证不能开始,因为此台设备没有设置密码.
            msg = @"未设置密码,无法开启认证!";
            break;
        case LAErrorSystemCancel:
            //认证被系统取消了,例如其他的应用程序到前台了
            msg = @"系统取消认证";
            break;
        case LAErrorUserFallback:
            //认证被取消,因为用户点击了fallback按钮(输入密码).
            msg = @"选择输入密码!";
            break;
        case LAErrorUserCancel:
            //认证被用户取消,例如点击了cancel按钮.
            msg = @"取消认证!";
            break;
        case LAErrorAuthenticationFailed:
            //认证没有成功,因为用户没有成功的提供一个有效的认证资格
            msg = @"认证失败!";
            break;
        default:
            break;
    }
    /// Authentication was not successful, because there were too many failed Touch ID attempts and
    /// Touch ID is now locked. Passcode is required to unlock Touch ID, e.g. evaluating
    /// LAPolicyDeviceOwnerAuthenticationWithBiometrics will ask for passcode as a prerequisite.
    //LAErrorTouchIDLockout   NS_ENUM_AVAILABLE(10_11, 9_0) __WATCHOS_AVAILABLE(3.0) __TVOS_AVAILABLE(10.0) = kLAErrorTouchIDLockout,
    
    /// Authentication was canceled by application (e.g. invalidate was called while
    /// authentication was in progress).
    //LAErrorAppCancel        NS_ENUM_AVAILABLE(10_11, 9_0) = kLAErrorAppCancel,
    
    /// LAContext passed to this call has been previously invalidated.
    //LAErrorInvalidContext   NS_ENUM_AVAILABLE(10_11, 9_0) = kLAErrorInvalidContext
    return msg;
}

#pragma mark -
#pragma mark Storage
- (BOOL)loadIsAuthenticationEnabledForFeature:(NSString *)featureName
{
    if (!USER_MGR.isLogin)
    {
        return NO;
    }
    long long userId = USER_MGR.user.user.userId;
    NSString *userIdStr = nil;
    if (userId <= 0)
    {
        return NO;
    }
    userIdStr = [NSString stringWithFormat:@"%lld", userId];
    NSDictionary *featuresDictionary = [[NSUserDefaults standardUserDefaults] valueForKey:userIdStr];
    return [[featuresDictionary valueForKey:featureName] boolValue];
}

- (void)setAuthenticationEnabled:(BOOL)isAuthenticationEnabled forFeature:(NSString *)featureName account:(NSString*)account
{
    if (!account || account.length <= 0)
    {
        return;
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *featuresDictionary = nil;
    NSDictionary *currentDictionary = [userDefaults valueForKey:account];
    if (currentDictionary == nil)
    {
        featuresDictionary = [NSMutableDictionary dictionary];
    } else {
        featuresDictionary = [NSMutableDictionary dictionaryWithDictionary:currentDictionary];
    }
    
    [featuresDictionary setValue:@(isAuthenticationEnabled) forKey:featureName];
    [userDefaults setValue:featuresDictionary forKey:account];
    [userDefaults synchronize];
}

- (void)setAuthenticationEnabledForDefault:(BOOL)isAuthenticationEnabled
{
    NSString *featureName = KFeatureNameForAppLock;
    if (!USER_MGR.isLogin)
    {
        return;
    }
    long long userId = USER_MGR.user.user.userId;
    NSString *userIdStr = nil;
    if (userId <= 0)
    {
        return;
    }
    userIdStr = [NSString stringWithFormat:@"%lld", userId];
    [self setAuthenticationEnabled:isAuthenticationEnabled forFeature:featureName account:userIdStr];
}

#pragma mark ---------------Utils----------------

- (NSError *)authenticationUnavailabilityError
{
    return [NSError errorWithDomain:KBiometricsErrorDomain
                               code:SQTouchLockErrorUnavailability
                           userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Authentication by Biometrics isn't available", nil)}];
}

- (NSError *)authenticationAlreadyPresentError
{
    return [NSError errorWithDomain:KBiometricsErrorDomain
                               code:SQTouchLockErrorPromptAlreadyPresent
                           userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Authentication by Biometrics Already Present", nil)}];
}

- (NSError *)authenticationUnSupportError
{
    return [NSError errorWithDomain:KBiometricsErrorDomain
                               code:SQTouchLockErrorTouchIDNotAvailable
                           userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Authentication by Biometrics unsupport", nil)}];
}
@end

