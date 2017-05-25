//
//  SocialAPISinaWeibo.h
//  
//
//  Created by Semny on 14-9-23.
//  Copyright (c) 2014年 Semny. All rights reserved.
//

#import "SocialAPIBasePlatform.h"
#import "WeiboSDK.h"

#define kSinaWeiboUserShowURL    @"https://api.weibo.com/2/users/show.json"
#define kSinaWeiboImageShareURL  @"https://upload.api.weibo.com/2/statuses/upload.json"
#define kSinaWeiboShareURL       @"https://api.weibo.com/2/statuses/update.json"

#define kSinaWeiboSSOLoginRequestTag            @"SinaWeiboLogin"
#define kSinaWeiboSSOLogoutRequestTag           @"SinaWeiboLogout"
#define kSinaWeiboShareRequestTag               @"SinaWeiboShare"
#define kSinaWeiboGetUserInfoRequestTag         @"SinaWeiboGetUserInfo"
//获取用户信息之前的登录
#define kSinaWeiboGetUserSSOLoginRequestTag     @"SinaWeiboGetUserSSOLogin"
//在登录过程中的获取用户信息
#define kSinaWeiboGetUserInLoginRequestTag     @"SinaWeiboGetUserInLogin"

//分享之前的登录
#define kSinaWeiboShareSSOLoginRequestTag       @"SinaWeiboShareSSOLogin"

#define KSinaWeiboResqonseKey                   @"SWResqonseKey"

//新浪微博用户信息
#define KSinaWeiboUserInfo              @"SWUserInfo"
//新浪微博校验token
#define KSinaWeiboAccessToken           @"SWAccessToken"
//新浪微博用户id
#define KSinaWeiboUserId                @"SWUserId"
//新浪微博认证的token过期时间的浮点数据
#define KSinaWeiboExpirationDate        @"SWExpirationDateValue"


@interface SocialAPISinaWeibo : SocialAPIBasePlatform<WeiboSDKDelegate>
//@property (assign, nonatomic) id <WBHttpRequestDelegate> httpDelegate;
@property (assign, nonatomic) BOOL enableDebugMode;  //默认为NO

- (instancetype)initWith:(NSDictionary *)userInfo;

/**
 *  初始化实例对象
 *
 *  @param userInfo 用户信息(新浪注册登录过后保存的)
 *  @param delegate HTTP代理对象
 *
 *  @return 实例对象
 */
- (instancetype)initWith:(NSDictionary *)userInfo delegate:(id <WBHttpRequestDelegate>)delegate;


/*! 检查手机是否安装微博客户端
 * @return BOOL  YES---已经安装；NO---未安装
 */
- (BOOL)isWeiboInstalled;

- (NSInteger)shareContentAndLoginWith:(SocialEntity *)content delegate:(id<SocialAPIDelegate>)delegate;

@end
