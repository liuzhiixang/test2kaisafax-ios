//
//  KSUserInfoBL.m
//  kaisafax
//
//  Created by semny on 16/7/28.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSUserInfoBL.h"
#import "KSUserMgr.h"


@implementation KSUserInfoBL

///**
// *  @author semny
// *
// *  获取当前用户的个人账户财富信息
// *
// *  @return 序列号
// */
//- (NSInteger)doGetUserAssets
//{
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
////    //TODO: 所有获取用户信息的地方都需要重新使用用户登录管理类
////    NSString *imeiStr = USER_SESSIONID;
////    if(imeiStr && imeiStr.length > 0)
////    {
////        [params setObject:imeiStr forKey:KUserIMEIKey];
////    }
//    NSString *tradeId = KUserAssetsTradeId;
//    //请求
//    return [self requestWithTradeId:tradeId data:params];
//}
//
///**
// *  @author semny
// *
// *  获取当前用户的个人账户财富信息
// *
// *  @param delegate 网络请求delegate
// *
// *  @return 序列号
// */
//- (NSInteger)doGetUserAssetsByDelegate:(id<SQRequestDelegate>)delegate
//{
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
////    //TODO: 所有获取用户信息的地方都需要重新使用用户登录管理类
////    NSString *imeiStr = USER_SESSIONID;
////    if(imeiStr && imeiStr.length > 0)
////    {
////        [params setObject:imeiStr forKey:KUserIMEIKey];
////    }
//    NSString *tradeId = KUserAssetsTradeId;
//    //请求
//    return [self requestWithTradeId:tradeId data:params delegate:delegate];
//}

/**
 *  @author semny
 *
 *  修改用户密码
 *
 *  @return 序列号
 */
- (NSInteger)doModifyUserPassword:(NSString *)oldPW newPW:(NSString *)newPW
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (oldPW)
    {
        [params setObject:oldPW forKey:kUserOldPwdKey];
    }
    if (newPW)
    {
        [params setObject:newPW forKey:kUserNewPwdKey];
    }
    NSString *tradeId = KModifyLoginPwdTradeId;
    //请求
    return [self requestWithTradeId:tradeId data:params];
}

/**
 *  @author semny
 *
 *  忘记密码后修改用户密码
 *
 *  @return 序列号
 */
- (NSInteger)doForgotUserPassword:(NSString *)newPW mobile:(NSString *)mobile verifyCode:(NSString*)verifyCode
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (newPW)
    {
        [params setObject:newPW forKey:kPasswordKey];
    }
    if (mobile)
    {
        [params setObject:mobile forKey:kMobileKey];
    }
    if (verifyCode)
    {
        [params setObject:verifyCode forKey:kVerifyCodeKey];
    }
    NSString *tradeId = KForgotPasswordTradeId;
    //请求
    return [self requestWithTradeId:tradeId data:params];
}

//同步用户信息到本地
- (NSInteger)doSyncUserInfo
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *tradeId = KSyncUserInfoTradeId;
    //请求
    return [self requestWithTradeId:tradeId data:params];
}

@end
