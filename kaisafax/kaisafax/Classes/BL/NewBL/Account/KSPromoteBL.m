//
//  KSPromoteBL.m
//  kaisafax
//
//  Created by semny on 16/8/4.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSPromoteBL.h"
#import "KSUserMgr.h"
#import "KSVersionMgr.h"

@implementation KSPromoteBL

/**
 *  @author semny
 *
 *  获取我的推广信息
 *
 *  @return 序列号
 */
- (NSInteger)doGetPromoteInfo
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    NSInteger platformType = kPlatformTypeValue;
//    [params setObject:@(platformType) forKey:kPlatformTypeKey];
//    NSString *appVersion = [[KSVersionMgr sharedInstance] getVersionName];
//    if (appVersion)
//    {
//        [params setObject:appVersion forKey:kAppVersionsKey];
//    }
//    NSString *appChannels = kChannelVID;
//    [params setObject:appChannels forKey:kAppChannelsKey];
//    NSString *switchAppRequest = kSwitchAppRequest2;
//    [params setObject:switchAppRequest forKey:kSwitchAppRequestNameKey];
    
    NSString *tradeId = KCommissionTradeId;
    return [self requestWithTradeId:tradeId data:params];
}

/**
 *  @author semny
 *
 *  获取我的推广收益信息
 *
 *  @return 序列号
 */
- (NSInteger)doGetPromoteIncomeInfo
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *tradeId = KCommissionIncomeTradeId;
    //请求
    return [self requestWithTradeId:tradeId data:params];
}

@end
