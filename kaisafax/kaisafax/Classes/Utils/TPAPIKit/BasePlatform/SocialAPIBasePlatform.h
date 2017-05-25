//
//  SocialAPIBasePlatform.h
//  
//
//  Created by Semny on 14-9-23.
//  Copyright (c) 2014年 Semny. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocialConfig.h"
#import "SocialEntity.h"

//分享错误
#define KSocialAPIResultErrorDomain       @"SocialAPIResultErrorDomain"
#define KSocialAPIResultErrorCodeKey       @"SocialAPIResultErrorCode"
#define KSocialAPIResultErrorMsgKey       @"SocialAPIResultErrorMsg"

//各个平台的操作代理
@protocol SocialAPIDelegate <NSObject>

@optional
/**
 *  @author semny
 *
 *  @param snsType 平台类型
 *  取消
 */
- (void)didCancleSocialAPIType:(NSInteger)snsType;

/**
 *  @author semny
 *
 *  分享失败
 *
 *  @param snsType 平台类型
 */
-(void)didFailedSocialAPIType:(NSInteger)snsType error:(NSError *)error;

/**
 *  @author semny
 *
 *  分享失败
 *
 *  @param snsType 平台类型
 */
-(void)didFinishSocialAPIType:(NSInteger)snsType;

@end


@interface SocialAPIBasePlatform : NSObject

/** 平台配置信息 */
@property (readonly, strong, nonatomic) NSDictionary *platformsConfigDic;
@property (nonatomic, weak) id<SocialAPIDelegate> delegate;

/** @brief 注册App
 *
 */
- (void)registerApp;

/** @brief 获取用户基本信息
 *
 * @return 序列号
 */
- (long)getUserInfo;

/**
 *  根据父流程的请求类型编号和序列号获取用户信息
 *
 *  @param pCmdId 父流程的请求类型编号
 *  @param pSeqNo 父流程的请求序列号
 *
 *  @return 当前接口请求的序列号
 */
- (long)getUserInfo:(NSInteger)pCmdId processSeqNo:(long)pSeqNo;

/** @brief 第三方SSO授权登录
 *
 * @return 序列号
 */
- (long)ssoLogin;

/** @brief 取消第三方SSO授权登录
 *
 * @return 序列号
 */
- (long)ssoLogout;

/** @brief 分享信息到社交平台
 *
 * @param contentDic 信息字典，字典的内容需要根据具体的平台而定
 * @return 序列号
 */
//- (long)shareContent:(NSMutableDictionary *)contentDic;

/**
 *  @author semny
 *
 *  分享信息到相关平台
 *
 *  @param content 数据内容
 *
 *  @return 序列号
 */
- (NSInteger)shareContentWith:(SocialEntity *)content;
- (NSInteger)shareContentWith:(SocialEntity *)content delegate:(id<SocialAPIDelegate>)delegate;

/**
 *  清理登录用户信息
 */
- (void)clearUserInfo;

/**
 *  根据请求返回的结果组合新的结果数据，增加了标志哪个流程的参数
 *
 *  @param result 原始结果参数
 *  @param tpType 流程类型
 *
 *  @return 新的结果数据
 */
- (NSDictionary *)composeTPResultBy:(NSDictionary *)result tpType:(int)tpType;

@end
