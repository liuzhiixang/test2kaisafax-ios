//
//  KSUserMgr.m
//  kaisafax
//
//  Created by semny on 16/7/26.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSUserMgr.h"
#import "KSAssetsBL.h"
#import "KSKeychain.h"
#import "KSLoginVC.h"
#import "KSUserInfoBL.h"
#import "NSUserDefaults+Coder.h"
//#import "KSNavigationVC.h"

@interface KSUserMgr () < KSBLDelegate >
{
    NSInteger _assetsRequestId;
}
@property (strong, nonatomic) KSLoginBL *loginBL;
@property (strong, nonatomic) KSUserInfoBL *userInfoBL;
@property (strong, nonatomic) KSAssetsBL *assetsBL;
//显示login登录模块的标志
@property (assign, nonatomic) BOOL isShowLogin;
@property (copy, nonatomic) NSString *assetsJSONString;

//登录状态会话
@property (weak, nonatomic) NSString *sessionId;

@end

@implementation KSUserMgr

@synthesize assets = _assets;
@synthesize user = _user;

+ (KSUserMgr *)sharedInstance
{
    static KSUserMgr *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      instance = [[KSUserMgr alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        //登录相关BL
        [self initLoginBL];
        [self initAssetsBL];
    }
    return self;
}

- (void)initLoginBL
{
    if (!_loginBL)
    {
        _loginBL = [[KSLoginBL alloc] init];
        _loginBL.delegate = self;
    }
}

- (void)initAssetsBL
{
    if (!_assetsBL)
    {
        _assetsBL = [[KSAssetsBL alloc] init];
        _assetsBL.delegate = self;
    }
}

- (void)initUserInfoBL
{
    if (!_userInfoBL)
    {
        _userInfoBL = [[KSUserInfoBL alloc] init];
        _userInfoBL.delegate = self;
    }
}

//- (void)setLoginDelegate:(id<KSBLDelegate>)loginDelegate
//{
//    if (_loginBL)
//    {
//        _loginBL.delegate = _loginDelegate;
//    }
//}
- (void)setUser:(KSUserInfoEntity *)user
{
    DEBUGG(@"%@ before set user: %@", self, _user);
    _user = user;
    DEBUGG(@"%@ after set user: %@", self, _user);
    _sessionId = user.sessionId;
}

- (void)setNewUser:(KSUserInfoEntity *)user
{
    if (!_user)
    {
        self.user = user;
        return;
    }
    _user.user = user.user;
    KSPNRAccountEntity *chinaPnrAccount = user.chinaPnrAccount;
    if (chinaPnrAccount && chinaPnrAccount.pnrUsrId && chinaPnrAccount.pnrUsrId.length > 0)
    {
        _user.chinaPnrAccount = user.chinaPnrAccount;
    }

    NSString *sessionId = user.sessionId;
    if (sessionId && sessionId.length > 0)
    {
        _user.sessionId = user.sessionId;
    }

    DEBUGG(@"%@ after set user: %@", self, _user);
    _sessionId = user.sessionId;
}

- (KSUserInfoEntity *)user
{
    DEBUGG(@"%@ before get user!", self);
    if (!_user)
    {
        DEBUGG(@"%@ _user111 is nil", self);
        _user = [[NSUserDefaults standardUserDefaults] decodeObjectForKey:KLoginUserEncryptedKey];
        DEBUGG(@"%@ _user222 is %@", self, _user);
    }
    return _user;
}

- (KSNewAssetsEntity *)assets
{
    if (!_assets)
    {
        DEBUGG(@"%@ assets111 is nil", self);
        _assets = [[NSUserDefaults standardUserDefaults] decodeObjectForKey:KNewAssetsInfo];
        DEBUGG(@"%@ assets222 is %@", self, _assets);
    }
    return _assets;
}

- (void)setAssets:(KSNewAssetsEntity *)assets
{
    _assets = assets;

    NSString *jsonString = [assets yy_modelToJSONString];
    _isAssetsChanged = ![_assetsJSONString isEqualToString:jsonString];
    if (_isAssetsChanged)
    {
        self.assetsJSONString = jsonString;
    }
}

- (BOOL)isLogin
{
    //    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    KSUserInfoEntity *loginUserInfo = self.user; //[userDefaults decodeObjectForKey:KLoginUserInfo];
    NSString *accessToken = loginUserInfo.sessionId;
    DEBUGG(@"%s accessToken: %@", __FUNCTION__, accessToken);
    if (!accessToken || [accessToken length] <= 0)
    {
        return NO;
    }

    DEBUGG(@"%s loginUserInfo: %@", __FUNCTION__, loginUserInfo);
    long long userId = loginUserInfo.user.userId;
    if (loginUserInfo && userId > 0)
    {
        return YES;
    }

    return NO;
}

- (void)syncCacheUserInfo
{
    DEBUGG(@"%@ before %s: %@", self, __FUNCTION__, _user);
    if (_user)
    {
        DEBUGG(@"%@ in  %s: %@", self, __FUNCTION__, _user);
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setEncodeObject:_user forKey:KLoginUserEncryptedKey];
        [userDefaults synchronize];

        //同步到数据库(不仅仅是用户表还包括其他相关的表)
        //[KSUserInfoBL updateUserInfo:_user];
    }
    DEBUGG(@"%@ after  %s: %@", self, __FUNCTION__, _user);
}

- (void)syncCacheAssets
{
    DEBUGG(@"%@ before %s: %@", self, __FUNCTION__, _assets);
    if (_assets)
    {
        DEBUGG(@"%@ in %s: %@", self, __FUNCTION__, _assets);
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setEncodeObject:_assets forKey:KNewAssetsInfo];
        [userDefaults synchronize];
    }
    DEBUGG(@"%@ after %s: %@", self, __FUNCTION__, _assets);
}

/**
 *  清理当前用户的登录信息（注销登录的时候使用）
 */
- (void)clearOwner
{
    DEBUGG(@"%@ %s: %@", self, __FUNCTION__, _user);
    //清理数据库的用户数据
    //[KSUserInfoBL deleteUserInfoByUserID:self.user.userId];

    // 清理登录用户信息
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //    [userDefaults removeObjectForKey:KSessionId];
    [userDefaults removeObjectForKey:KLoginUserEncryptedKey];
    [userDefaults removeObjectForKey:KNewAssetsInfo];
    [userDefaults synchronize];

    //清理当前的用户信息
    if (self.user)
    {
        self.user = nil;
    }
    if (self.assets)
    {
        self.assets = nil;
    }
}

- (BOOL)isOwnerByUserInfo:(KSUserInfoEntity *)userInfo;
{
    BOOL isCurrentLoginUser = NO;
    long long userId = self.user.user.userId;
    if (userId == userInfo.user.userId)
    {
        isCurrentLoginUser = YES;
    }
    return isCurrentLoginUser;
}

/**
 *  @author semny
 *
 *  获取当前的用户imei
 *
 *  @return 当前用户的imei
 */
- (NSString *)getCurrentSessionId
{
    if (!_sessionId || _sessionId.length <= 0)
    {
        _sessionId = self.user.sessionId;
    }
    return _sessionId;
}

#pragma mark-----登录相关操作--------
/**
 * 通过手机账号登录
 * @param mobileNo   手机号
 * @param password   密码
 */
- (NSInteger)doLoginByMobile:(NSString *)mobileNo andPassaword:(NSString *)password
{
    [self initLoginBL];
    return [_loginBL doLoginByMobile:mobileNo andPassaword:password];
}

///**
// * Token登录
// */
//- (NSInteger)doLoginByToken
//{
//    //TODO:什么都是假的，这个接口坐等服务端实现
//    long long seqNo = [_loginBL doLoginByAccessToken];
//    KSResponseEntity *response = [KSResponseEntity responseFromTradeId:KLoginTokenTradeId sid:seqNo body:nil];
//    [_loginBL succeedCallbackWithResponse:response];
//    return seqNo;
//}
//
///**
// * Token登录
// */
//- (NSInteger)doLoginByTokenWith:(id)user
//{
//    //TODO:什么都是假的，这个接口坐等服务端实现
//    long long seqNo = [_loginBL doLoginByAccessToken];
//    KSResponseEntity *response = [KSResponseEntity responseFromTradeId:KLoginTokenTradeId sid:seqNo body:user];
//    [_loginBL succeedCallbackWithResponse:response];
//    return seqNo;
//}

/**
 *  当前用户登录态注销
 *
 *  @return 请求序列号
 */
//- (NSInteger)doLogout
//{
//    return [_loginBL doLogout];
//}

- (NSInteger)doLogout
{
    [self initLoginBL];
    long long seqNo = [_loginBL doLogout];
    int loginPathType = LoginPathInProcess;
    //处理注销登录后的操作
    [USER_MGR handleLoginStateInvalid:loginPathType loginType:LoginTypeByLogin];
    //清理数据
    [self clearOwner];

    return seqNo;
}

- (void)updateUserAssets
{
    if ([USER_MGR isLogin])
    {
        _assetsRequestId = [_assetsBL doGetUserNewAssets];
    }
    else
    {
        self.assets = nil;
    }
}

////刷新session
//- (NSInteger)doRefreshSessionId
//{
//    long long seqNo = -1;
//    if ([self isLogin])
//    {
//        [self initLoginBL];
//        seqNo = [_loginBL doRefreshSessionId];
//    }
//    return seqNo;
//}

//获取当前用户信息
- (NSInteger)doGetUserInfo
{
    long long seqNo = -1;
    if ([self isLogin])
    {
        [self initUserInfoBL];
        seqNo = [_userInfoBL doSyncUserInfo];
    }
    return seqNo;
}

#pragma mark------判断登录并弹出登录界面----------
/**
 *  @author semny
 *
 *  判断并且跳转登录页面的方法
 *
 *  @param controller 调用跳转的VC
 *
 *  @return YES:已经登录;NO:未登录，并且跳转登录页面
 */
- (BOOL)judgeLoginForVC:(UIViewController *)controller
{
    DEBUGG(@"%s Login1111 %@", __FUNCTION__, controller);
    return [self judgeLoginForVC:controller needEndAnimation:NO];
}

- (BOOL)judgeLoginForVC:(UIViewController *)controller needEndAnimation:(BOOL)needEndAnimation
{
    return [self judgeLoginForVC:controller needEndAnimation:needEndAnimation completion:nil];
}

/**
 *  @author semny
 *
 *  判断并且跳转登录页面的方法
 *
 *  @param controller 调用跳转的VC
 *
 *  @return YES:已经登录;NO:未登录，并且跳转登录页面
 */
- (BOOL)judgeLoginForVC:(UIViewController *)controller needEndAnimation:(BOOL)needEndAnimation completion:(void (^)(void))completion
{
    DEBUGG(@"%s Login1111 %@", __FUNCTION__, controller);
    if (![self isLogin])
    {
        if (controller && !_isShowLogin)
        {
            //登录启动之前的通知
            if (needEndAnimation)
            {
                DEBUGG(@"%s Login2222 %@", __FUNCTION__, controller);
                [NOTIFY_CENTER postNotificationName:KLoginPageBeginAnimationNotificationKey object:nil userInfo:nil];
            }
            DEBUGG(@"%s Login5555 %@", __FUNCTION__, controller);
            NSString *userName = [self getFirstLoginHistoryAccount];
            KSLoginVC *loginVC = [[KSLoginVC alloc] initWithUserName:userName];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
            @WeakObj(self);
            [controller presentViewController:nav
                                     animated:YES
                                   completion:^{
                                     //启动完成后
                                     weakself.isShowLogin = YES;
                                     if (completion)
                                     {
                                         completion();
                                     }
                                   }];
        }
        return NO;
    }
    else
    {
        //TODO: Test data login in background
    }
    DEBUGG(@"%s Login3333 %@", __FUNCTION__, controller);

    return YES;
}

- (void)dismissLoginProgressFor:(UIViewController *)controller completion:(void (^)(void))completion
{
    if (controller)
    {
        DEBUGG(@"%s Login2222 %@", __FUNCTION__, controller);
        @WeakObj(self);
        [controller dismissViewControllerAnimated:YES
                                       completion:^{
                                         //发关闭通知
                                         [NOTIFY_CENTER postNotificationName:KLoginPageCloseAnimationNotificationKey object:nil userInfo:nil];
                                         //关闭登录完成后
                                         weakself.isShowLogin = NO;
                                         if (completion && completion != NULL)
                                         {
                                             completion();
                                         }
                                       }];
    }
}

#pragma mark-------用户本地配置------------
//获取登录历史记录的第一个用户账户
- (NSString *)getFirstLoginHistoryAccount
{
    KSKeychainAttribute *accountData = [KSKeychain findOneAccount];
    NSString *userName = accountData.account;
    return userName;
}

//设置当前用户的密码缓存
- (void)setPasswordForCurrentUserWith:(NSString *)password
{
    if (self.isLogin && password.length > 0)
    {
        //原来是手机号，重构去掉了手机号字段
        NSString *userName = self.user.user.loginName;
        //保存密码
        [KSKeychain setPassword:password account:userName];
    }
}

//设置当前用户的密码缓存
- (void)setPasswordForCurrentUserWith:(NSString *)password account:(NSString *)account
{
    if (self.isLogin && password.length > 0 && account.length > 0)
    {
        //原来是手机号，重构去掉了手机号字段
        NSString *userName = account;
        //保存密码
        [KSKeychain setPassword:password account:userName];
    }
}

////设置session
//- (void)setSessionIdForCurrentUserWith:(NSString*)sessionId
//{
//    //TODO:后续需要完善，使用keychain
//    if (!sessionId || sessionId.length <= 0)
//    {
//        return;
//    }
//    //后续登录使用到的token数据
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    [userDefaults setObject:sessionId forKey:KSessionId];
//    [userDefaults synchronize];
//}

////获取token
//- (NSString *)getSessionIdForCurrentUser
//{
//    //TODO:后续需要完善，使用keychain
//    //后续登录使用到的token数据
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    return [userDefaults objectForKey:KSessionId];
//}

//设置当前用户的账户信息的隐藏标志
- (void)setUserAssetsHiddenFlagForUser:(long long)userId With:(BOOL)hidden
{
    if (self.isLogin)
    {
        //后续登录使用到的token数据
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *accountStr = [NSString stringWithFormat:@"%lld_%@", userId, KUserAssetsHiddenKey];
        [userDefaults setObject:@(hidden) forKey:accountStr];
        INFO(@"/*****************%s******************/ \n userId:%lld hidden status:%@", __FUNCTION__, userId, @(hidden));
        [userDefaults synchronize];
    }
}

//获取当前用户的账户信息的隐藏标志
- (BOOL)getUserAssetsHiddenFlagForUser:(long long)userId
{
    //hidden:YES  selected:NO
    BOOL flag = NO;
    if (self.isLogin)
    {
        //后续登录使用到的token数据
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *accountStr = [NSString stringWithFormat:@"%lld_%@", userId, KUserAssetsHiddenKey];
        NSNumber *hiddenNum = [userDefaults objectForKey:accountStr];
        if (!hiddenNum)
            return NO;
        flag = hiddenNum.boolValue;
    }
    return flag;
}

//登录或者注册的时候去通知账户中心的标志位
- (void)setUserAssetsHiddenFlagAccordingtoRegisterOrLogin:(BOOL)isLogin
{
    if (self.isLogin)
    {
        //检测是否没有存储过的新的账户
        long long userId = USER_MGR.user.user.userId;
        BOOL eyeShow = NO;
        if (isLogin)
        {
            NSString *accountStr = [NSString stringWithFormat:@"%lld_%@", userId, KUserAssetsHiddenKey];
            NSNumber *hiddenNum = [[NSUserDefaults standardUserDefaults] objectForKey:accountStr];
            //如果为空就是新账户了；如果不为空就是已有的，传送已经存在nsdefault的值
            if (hiddenNum)
            {
                eyeShow = [hiddenNum boolValue];
            }
        }
        [USER_MGR setUserAssetsHiddenFlagForUser:userId With:eyeShow];
        [[NSNotificationCenter defaultCenter] postNotificationName:KChangeAccountEyeFlagKey object:nil userInfo:@{ @"eyeBtnFlag" : @(eyeShow) }];
    }
}
#pragma mark -
#pragma mark----------------登录态改变的通知-------------------
/**
 *  注销登录后的操作处理
 */
- (void)handleLoginStateInvalid:(NSInteger)loginPath loginType:(NSInteger)loginType
{
    DEBUGG(@"%@ %s", self, __FUNCTION__);
    if ([USER_MGR isLogin])
    {
        self.assetsJSONString = nil;
        self.isAssetsChanged = YES;
        //发送登录的通知
        NSDictionary *result = @{KLoginStatus : [NSNumber numberWithBool:NO], KLoginPathInAction : [NSNumber numberWithInteger:loginPath], KLoginTypeInAction : [NSNumber numberWithInteger:loginType]};
        [[NSNotificationCenter defaultCenter] postNotificationName:KLoginStatusNotification object:result];
    }
}

/**
 *  登录后的操作处理
 */
- (void)handleLoginStateValid:(NSInteger)loginPath loginType:(NSInteger)loginType
{
    //只有是当前登录的用户以及用户信息不为空的时候才能发出登录状态成功的通知
    if ([USER_MGR isLogin])
    {
        NSDictionary *result = @{KLoginStatus : [NSNumber numberWithBool:YES], KLoginPathInAction : [NSNumber numberWithInteger:loginPath], KLoginTypeInAction : [NSNumber numberWithInteger:loginType]};
        DEBUGG(@"%@ %s: %@", self, __FUNCTION__, result);
        [[NSNotificationCenter defaultCenter] postNotificationName:KLoginStatusNotification object:result];
    }
}

#pragma mark - KSBLDelegate
- (void)finishedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)result
{
    long long seqNo = result.sid;
    NSString *tradeId = result.tradeId;
    id bodyObj = result.body;

    //登录相关
    if ([blEntity isKindOfClass:[KSLoginBL class]])
    {
        //回调处理
        if (SecureDelegateMethodJudger(self.loginDelegate, finishedHandle
                                       : response:))
        {
            [self.loginDelegate finishedHandle:self.loginBL response:result];
        }

        //session的处理
        if ([tradeId isEqualToString:KRefreshSessionIdTradeId])
        {
            NSDictionary *bodyDict = nil;
            if (bodyObj && [bodyObj isKindOfClass:[NSDictionary class]])
            {
                bodyDict = (NSDictionary *)bodyObj;
            }

            //成功的暂时不需要处理
            NSString *sessionId = [bodyDict objectForKey:kSessionIdKey];
            self.user.sessionId = sessionId;
            //            [self setSessionIdForCurrentUserWith:sessionId];
            [self syncCacheUserInfo];
        }
    }
    else if ([tradeId isEqualToString:KUserNewAssetsTradeId])
    {
        //账户信息
        if (seqNo == _assetsRequestId)
        {
            self.assets = result.body;
            [self syncCacheAssets];
        }
    }
    else if ([tradeId isEqualToString:KSyncUserInfoTradeId])
    {
        //同步用户信息
        KSUserInfoEntity *userInfo = result.body;
        if ([userInfo isKindOfClass:[KSUserInfoEntity class]])
        {
            [self setNewUser:userInfo];
            [self syncCacheUserInfo];
        }
    }
}

- (void)failedHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)result
{
    long long seqNo = result.sid;
    NSString *tradeId = result.tradeId;
    //登录相关
    if ([blEntity isKindOfClass:[KSLoginBL class]])
    {
        //回调处理
        if (SecureDelegateMethodJudger(self.loginDelegate, failedHandle
                                       : response:))
        {
            [self.loginDelegate failedHandle:self.loginBL response:result];
        }
    }
    else if ([tradeId isEqualToString:KUserNewAssetsTradeId])
    {
        //账户信息
        if (seqNo == _assetsRequestId)
        {
            //发射一个空信号, 告改这个请求完成了
            [self willChangeValueForKey:@"assets"];
            [self didChangeValueForKey:@"assets"];
        }
    }
    else if ([tradeId isEqualToString:KSyncUserInfoTradeId])
    {
        //同步用户信息
    }
}

- (void)sysErrorHandle:(KSBaseBL *)blEntity response:(KSResponseEntity *)result
{
    long long seqNo = result.sid;
    NSString *tradeId = result.tradeId;
    //登录相关
    if ([blEntity isKindOfClass:[KSLoginBL class]])
    {
        //回调处理
        if (SecureDelegateMethodJudger(self.loginDelegate, sysErrorHandle
                                       : response:))
        {
            [self.loginDelegate sysErrorHandle:self.loginBL response:result];
        }
    }
    else if ([tradeId isEqualToString:KUserNewAssetsTradeId])
    {
        //账户信息
        if (seqNo == _assetsRequestId)
        {
            //发射一个空信号, 告改这个请求完成了
            [self willChangeValueForKey:@"assets"];
            [self didChangeValueForKey:@"assets"];
        }
    }
    else if ([tradeId isEqualToString:KSyncUserInfoTradeId])
    {
        //同步用户信息
    }
}
@end
