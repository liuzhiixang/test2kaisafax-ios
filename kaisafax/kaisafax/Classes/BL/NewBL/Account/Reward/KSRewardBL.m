//
//  KSRewardBL.m
//  kaisafax
//
//  Created by semny on 16/8/3.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSRewardBL.h"
#import "KSUserMgr.h"

@implementation KSRewardBL

/**
 *  @author semny
 *
 *  获取可提取奖励信息（红包）
 *
 *  @return 序列号
 */
- (NSInteger)doGetValidRewardsForRed
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    //TODO: 所有获取用户信息的地方都需要重新使用用户登录管理类
//    NSString *imeiStr = USER_SESSIONID;
//    if(imeiStr && imeiStr.length > 0)
//    {
//        [params setObject:imeiStr forKey:KUserIMEIKey];
//    }
    NSString *tradeId = KGetValidRewardsForRedTradeId;
    //请求
    return [self requestWithTradeId:tradeId data:params];
}

/**
 *  @author semny
 *
 *  获取可提取奖励信息（红包+推广）
 *
 *  @return 序列号
 */
/*- (NSInteger)doGetValidRewardsForAll
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *tradeId = KGetValidRewardsNewTradeId;
    //请求
    return [self requestWithTradeId:tradeId data:params];
}*/

/**
 *  @author semny
 *
 *  获取可提取奖励信息（现金券+红包+推广 明细）
 *
 *  @return 序列号
 */
- (NSInteger)doGetValidRewardsForDetail
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *tradeId = KGetValidRewardsDetailTradeId;
    //请求
    return [self requestWithTradeId:tradeId data:params];
}

/**
 *  @author semny
 *
 *  提取奖励
 *
 *  @return 序列号
 */
- (NSInteger)doTakeRewardCashWith:(NSString *)value
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if(value)
    {
        [params setObject:value forKey:kWithdrawAmtKey];
    }
    NSString *tradeId = KTakeRewardCashTradeId;
    //请求
    return [self requestWithTradeId:tradeId data:params];
}


/**
 *  @author semny
 *
 *  获取用户注册后的红包(注册红包)
 *
 *  @return 序列号
 */
- (NSInteger)doGetRegisterRedpacket
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    //TODO: 所有获取用户信息的地方都需要重新使用用户登录管理类
//    NSString *imeiStr = USER_SESSIONID;
//    if(imeiStr && imeiStr.length > 0)
//    {
//        [params setObject:imeiStr forKey:KUserIMEIKey];
//    }
    NSString *tradeId = KRegisterRedpacketTradeId;
    //请求
    return [self requestWithTradeId:tradeId data:params];
}

@end
