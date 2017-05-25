//
//  SQTouchLockMgr.h
//  kaisafax
//
//  Created by semny on 16/11/10.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <Foundation/Foundation.h>
// Error codes
//#define kLAErrorAuthenticationFailed                       -1
//#define kLAErrorUserCancel                                 -2
//#define kLAErrorUserFallback                               -3
//#define kLAErrorSystemCancel                               -4
//#define kLAErrorPasscodeNotSet                             -5
//#define kLAErrorTouchIDNotAvailable                        -6
//#define kLAErrorTouchIDNotEnrolled                         -7
//#define kLAErrorTouchIDLockout                             -8
//#define kLAErrorAppCancel                                  -9
//#define kLAErrorInvalidContext                            -10

typedef NS_ENUM(NSInteger, SQTouchLockError)
{
    SQTouchLockErrorUnavailability = 2,
    SQTouchLockErrorPromptAlreadyPresent = 1,
    /// Authentication was not successful, because user failed to provide valid credentials.
    SQTouchLockErrorAuthenticationFailed =  -1,
    
    /// Authentication was canceled by user (e.g. tapped Cancel button).
    SQTouchLockErrorUserCancel           =  -2,
    
    /// Authentication was canceled, because the user tapped the fallback button (Enter Password).
    SQTouchLockErrorUserFallback         =  -3,
    
    /// Authentication was canceled by system (e.g. another application went to foreground).
    SQTouchLockErrorSystemCancel         =  -4,
    
    /// Authentication could not start, because passcode is not set on the device.
    SQTouchLockErrorPasscodeNotSet       =  -5,
    
    /// Authentication could not start, because Touch ID is not available on the device.
    SQTouchLockErrorTouchIDNotAvailable  =  -6,
    
    /// Authentication could not start, because Touch ID has no enrolled fingers.
    SQTouchLockErrorTouchIDNotEnrolled =  -7,
    
    /// Authentication was not successful, because there were too many failed Touch ID attempts and
    /// Touch ID is now locked. Passcode is required to unlock Touch ID, e.g. evaluating
    /// LAPolicyDeviceOwnerAuthenticationWithBiometrics will ask for passcode as a prerequisite.
    SQTouchLockErrorTouchIDLockout =  -8,
    
    /// Authentication was canceled by application (e.g. invalidate was called while
    /// authentication was in progress).
    SQTouchLockErrorAppCancel =  -9,
    
    /// LAContext passed to this call has been previously invalidated.
    SQTouchLockErrorInvalidContext =  -10
} NS_ENUM_AVAILABLE(10_10, 8_0);

typedef NS_ENUM(NSInteger, SQTouchLockPolicy)
{
    SQTouchLockPolicyAuthenticationWithBiometrics = 1, //指纹
    SQTouchLockPolicyAuthentication = 2 //手机密码
    
} NS_ENUM_AVAILABLE(10_10, 8_0);

@interface SQTouchLockMgr : NSObject
//如下三个参数在统一使用的时候只需要设置一次
//其他操作的title
@property (nonatomic, copy) NSString *fallbackTitle;
//取消操作的title
@property (nonatomic, copy) NSString *cancelTitle;
//指纹验证的原因信息
@property (nonatomic, copy) NSString *reason;
//指纹验证失败次数超限后是否自动校验密码(默认校验)
@property (nonatomic, assign) BOOL needPasswordForMaxBiometryFailed;
//密码验证完成后是否需要校验指纹
@property (nonatomic, assign) BOOL needCheckBiometryAfterPasscode;

/**
 *  @author semny
 *
 *  初始化Touch id管理工具
 *
 *  @return Touch id管理工具单例对象
 */
+ (SQTouchLockMgr *)sharedInstance;

#pragma mark - 工具方法
//判断是否支持touch id
- (BOOL)isSupportTouchID;

//判断是否支持指纹密码
- (BOOL)isAuthenticationEnabledByBiometrics;

//判断是否touch id可用
- (BOOL)isAuthenticationEnabledByBiometricsWithError:(NSError * __autoreleasing *)error;

//判断featureName的功能名称下 touchID是否有效 是否开启开关 error处理
- (BOOL)isAuthenticationEnabledForFeature:(NSString *)featureName error:(NSError * __autoreleasing *)error;
//判断featureName的功能名称下 touchID是否有效 是否开启开关
//- (BOOL)isAuthenticationEnabledForFeature:(NSString *)featureName;
//判断默认的功能名称下 touchID是否有效 是否开启开关
- (BOOL)isAuthenticationEnabledForDefaultFeatureWithError:(NSError * __autoreleasing *)error;

//判断默认的功能名称下 touchID是否有效 是否开启开关 登录
- (BOOL)isAuthenticationEnabledForDefaultFeatureAndLogin;

//判断默认的功能名称下 touchID是否有效 是否开启开关
- (BOOL)isAuthenticationEnabledForDefaultFeature;

//开启指纹校验开关
//- (void)enableAuthenticationWithSuccesBlock:(void(^)(SQTouchLockPolicy policy))successBlock failureBlock:(void(^)(NSError *error))failureBlock;
//
////开启指纹校验开关（功能模块名称）
//- (void)enableAuthenticationForFeature:(NSString *)featureName succesBlock:(void(^)(SQTouchLockPolicy policy))successBlock failureBlock:(void(^)(NSError *error))failureBlock;

//关闭指纹校验开关
//- (void)disableAuthenticationWithReason:(NSString *)reason succesBlock:(void(^)(SQTouchLockPolicy policy))successBlock failureBlock:(void(^)(NSError *error))failureBlock;
//
////关闭指纹校验开关（功能模块名称）
//- (void)disableAuthenticationForFeature:(NSString *)featureName reason:(NSString *)reason succesBlock:(void(^)(SQTouchLockPolicy policy))successBlock failureBlock:(void(^)(NSError *error))failureBlock;

//只校验指纹
- (void)authenticateForAccessWithReason:(NSString *)reason succesBlock:(void(^)(SQTouchLockPolicy policy))successBlock failureBlock:(void(^)(NSError *error))failureBlock;

//只校验指纹（功能模块名称）
- (void)authenticateForAccessToFeature:(NSString *)featureName reason:(NSString *)reason succesBlock:(void(^)(SQTouchLockPolicy policy))successBlock failureBlock:(void(^)(NSError *error))failureBlock;

//优先判断是否可用和开关, 然后使用指纹校验功能
- (void)authenticateForAccessAndSwitchWithReason:(NSString *)reason succesBlock:(void(^)(SQTouchLockPolicy policy))successBlock failureBlock:(void(^)(NSError *error))failureBlock;

//优先判断是否可用和开关, 然后使用指纹校验功能（功能模块名称）
- (void)authenticateForAccessAndSwitchToFeature:(NSString *)featureName reason:(NSString *)reason succesBlock:(void(^)(SQTouchLockPolicy policy))successBlock failureBlock:(void(^)(NSError *error))failureBlock;

//设置校验开关标志
- (void)setAuthenticationEnabledForDefault:(BOOL)isAuthenticationEnabled;

@end
