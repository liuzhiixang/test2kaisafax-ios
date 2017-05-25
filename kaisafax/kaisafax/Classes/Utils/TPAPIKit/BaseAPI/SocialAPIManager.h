//
//  SocialAPIManager.h
//
//
//  Created by Semny on 14-9-19.
//  Copyright (c) 2014年 Semny. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocialAPISinaWeibo.h"
#import "SocialAPIWeChat.h"
#import "SocialAPITencentQQ.h"
#import "SocialEntity.h"
#import "SocialConfig.h"

@interface SocialAPIManager : NSObject

+ (SocialAPIManager *)sharedInstance;

/*! @brief 注册App
 *
 * @param platforms 可以包括：WeChat, QQ, SinaWeibo
 * @return 空值
 */
- (void)registerAppWithPlatforms:(NSArray *)platforms;

/*! @brief 判断客户端是否安装
 *
 * @param client 客户端类型
 * @return YES:已经安装 NO:未安装
 */
- (BOOL)isSSOClientInstalled:(SocialAPISSOType)client;

/*! @brief 获取用户基本信息
 *
 * @param type 授权方式
 * @return 序列号
 */
- (long)getUserInfoByType:(SocialAPISSOType)type;

/**
 *  根据平台类型获取用户信息，在子流程使用
 *
 *  @param type   平台类型
 *  @param pCmdId 父流程请求类型
 *  @param pSeqNo 父流程请求序列号
 *
 *  @return 请求序列号
 */
- (long)getUserInfoByType:(SocialAPISSOType)type processCmdId:(NSInteger)pCmdId processSeqNo:(long)pSeqNo;

/*! @brief 第三方SSO授权登录
 *
 * @param loginType 授权登录方式
 * @return 序列号
 */
- (long)ssoLoginByType:(SocialAPISSOType)loginType;

/*! @brief 取消第三方SSO授权登录
 *
 * @param loginType 授权登录方式
 * @return 序列号
 */
- (long)ssoLogoutByType:(SocialAPISSOType)logoutType;

/*! @brief 分享信息到社交平台
 *
 * @param contentDic 信息字典
 * @param platform 社交平台
 * @return 空值
 */
//- (void)shareContent:(NSMutableDictionary *)contentDic toPlatform:(SocialAPISNSType)platform;
- (void)shareContent:(SocialEntity *)content toPlatform:(SocialAPISNSType)platform;

/**
 *  处理第三方登录或者分享后返回当前APP的情况
 *
 *  @param url               需要处理的第三方跳转的URL
 *  @param sourceApplication 第三方来源标志
 *  @param annotation        描述注解
 *
 *  @return 是否跳转成功
 */
- (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

@end
