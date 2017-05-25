//
//  KSUserMgr.h
//  kaisafax
//
//  Created by semny on 16/7/26.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSUserInfoEntity.h"
#import "KSLoginBL.h"
//#import "KSUserAssetsEntity.h"
#import "KSNewAssetsEntity.h"

#define USER_MGR [KSUserMgr sharedInstance]
#define USER_SESSIONID USER_MGR.getCurrentSessionId


//登录后的session id
//#define KSessionId               @"NewSessionId"

//登录后的token
//#define KAccessToken               @"NewAccessToken"
#define KLoginUserEncryptedKey     @"LoginUserEncrypted"
#define KNewAssetsInfo             @"NewAssetsInfo"

//登录状态改变通知
#define KLoginStatusNotification   @"LoginStatusNotification"
#define KLoginStatus               @"LoginStatus"

//刷新账户中心的通知
#define KAssetUpdateNotification   @"AssetStatusNotification"
//充值成功提示
#define KRechargeNotification   @"KRechargeNotification"
//投资成功
#define KInvestSuccessNotification @"KInvestSuccessNotification"
//登录的入口
#define KLoginPathInAction               @"LoginPath"
#define KLoginTypeInAction               @"LoginType"
#define KUserAccountInAction             @"UserAccount"
#define KUserIdInAction                  @"UserId"

#define KUserAssetsHiddenKey @"user.assets.hidden.key"

typedef enum
{
    LoginPathInStart=1,       //从起始流程的登录/或者需要去到起始位置的注销登录
    LoginPathInProcess,        //在流程中的登录
}LoginPath;

typedef enum
{
    LoginTypeByLogin=1,       //登录使用login接口
    LoginTypeByRegister=2,    //登录使用register接口
    LoginTypeByToken=2,       //登录使用使用token接口
}LoginType;

/**
 *  @author semny
 *
 *  管理用户信息及登录态相关的
 */
@interface KSUserMgr : NSObject
//用户基本信息
@property (nonatomic, strong) KSUserInfoEntity *user;
//用户账户信息(财富等)
@property (nonatomic, strong) KSNewAssetsEntity *assets;

@property (nonatomic, assign) BOOL isAssetsChanged;

//登录相关的delegate
@property (nonatomic, weak) id<KSBLDelegate> loginDelegate;

+ (KSUserMgr *)sharedInstance;

/**
 *  判断是否登录
 *
 *  @return YES:登录成功; NO:没有登录；
 */
- (BOOL)isLogin;

/**
 *  同步用户数据,一般在请求或者数据有更新的情况使用,暂时放在setUser中
 */
- (void)syncCacheUserInfo;

/**
 *  @author semny
 *
 *  同步账户财富信息
 */
- (void)syncCacheAssets;

/**
 *  清理当前用户的登录信息（注销登录的时候使用）
 */
- (void)clearOwner;

/**
 *  判断是否 是当前登录的用户
 *
 *  @param userInfo 用户实例对象
 *
 *  @return YES：是当前登录的用户；NO:不是
 */
- (BOOL)isOwnerByUserInfo:(KSUserInfoEntity *)userInfo;

/**
 *  @author semny
 *
 *  获取当前的用户imei
 *
 *  @return 当前用户的imei
 */
- (NSString *)getCurrentSessionId;

//填充新的用户数据(由于部分接口数据不统一)
- (void)setNewUser:(KSUserInfoEntity *)user;

//#pragma mark ----------登录态改变的通知-------------------
///**
// *  注销登录后的操作处理
// */
//- (void)handleLoginStateInvalid;
//
///**
// *  登录后的操作处理
// */
//- (void)handleLoginStateValid;

#pragma mark -----登录相关操作--------
/**
 * 通过手机账号登录
 * @param mobileNo   手机号
 * @param password   密码
 */
- (NSInteger)doLoginByMobile:(NSString *)mobileNo andPassaword:(NSString *)password;

///**
// * Token登录(后续接口完善了使用这个方法)
// */
//- (NSInteger)doLoginByToken;
///**
// * Token登录(后续接口完善了废弃这个方法)
// */
//- (NSInteger)doLoginByTokenWith:(id)user;

/**
 *  当前用户登录态注销(暂时只能搞个假的退出登录)
 *
 *  @return 请求序列号
 */
- (NSInteger)doLogout;

/**
 *  更新已登录用户的assets
 */
- (void)updateUserAssets;

//刷新session
//- (NSInteger)doRefreshSessionId;

//获取当前用户信息
- (NSInteger)doGetUserInfo;

#pragma mark -
#pragma mark ----------------登录态改变的通知-------------------
/**
 *  注销登录后的操作处理
 */
- (void)handleLoginStateInvalid:(NSInteger)loginPath loginType:(NSInteger)loginType;

/**
 *  登录后的操作处理
 */
- (void)handleLoginStateValid:(NSInteger)loginPath loginType:(NSInteger)loginType;

#pragma mark -
/**
 *  @author semny
 *
 *  判断并且跳转登录页面的方法
 *
 *  @param controller 调用跳转的VC
 *
 *  @return YES:已经登录;NO:未登录，并且跳转登录页面
 */
- (BOOL)judgeLoginForVC:(UIViewController *)controller;

- (BOOL)judgeLoginForVC:(UIViewController *)controller needEndAnimation:(BOOL)needEndAnimation;

/**
 *  @author semny
 *
 *  判断并且跳转登录页面的方法
 *
 *  @param controller 调用跳转的VC
 *
 *  @return YES:已经登录;NO:未登录，并且跳转登录页面
 */
- (BOOL)judgeLoginForVC:(UIViewController *)controller needEndAnimation:(BOOL)needEndAnimation completion:(void (^)(void))completion;

//关闭登录注册相关的流程
- (void)dismissLoginProgressFor:(UIViewController *)controller completion:(void (^)(void))completion;

#pragma mark -------用户本地配置------------
//获取登录历史记录的第一个用户账户
- (NSString*)getFirstLoginHistoryAccount;

//设置当前用户的密码缓存
//- (void)setPasswordForCurrentUserWith:(NSString*)password;

//设置当前用户的密码缓存
- (void)setPasswordForCurrentUserWith:(NSString*)password account:(NSString*)account;

//设置session
//- (void)setSessionIdForCurrentUserWith:(NSString*)sessionId;

//获取token
//- (NSString *)getSessionIdForCurrentUser;

/**
 仅仅设置当前用户的标志位是不够的，需要把所有切换的用户的标志位都存下来
 */
//设置当前用户的账户信息的隐藏标志
- (void)setUserAssetsHiddenFlagForUser:(long long)userId With:(BOOL)hidden;

//获取当前用户的账户信息的隐藏标志
- (BOOL)getUserAssetsHiddenFlagForUser:(long long)userId;
//登录或者注册的时候去通知账户中心的标志位
- (void)setUserAssetsHiddenFlagAccordingtoRegisterOrLogin:(BOOL)isLogin;

@end
