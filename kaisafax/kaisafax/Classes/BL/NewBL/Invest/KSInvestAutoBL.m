//
//  KSInvestAutoBL.m
//  kaisafax
//
//  Created by semny on 16/11/23.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSInvestAutoBL.h"

@implementation KSInvestAutoBL

//获取自动投标的配置信息
- (NSInteger)doGetAutoInvestInfo
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *tradeId = KGetAutoInvestInfoTradeId;
    //请求
    return [self requestWithTradeId:tradeId data:params];
}

//保存自动投标的配置信息
- (NSInteger)doSaveAutoInvestInfoWithMinRate:(NSInteger)minRate maxRate:(NSInteger)maxRate minAmount:(NSInteger)minAmount maxAmount:(NSInteger)maxAmount reservedAmount:(NSString *)reservedAmount repayMethodIndex:(NSInteger)repayMethodIndex minDays:(NSInteger)minDays maxDays:(NSInteger)maxDays durType:(NSInteger)durType
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@(minRate) forKey:kMinRateKey];
    [params setObject:@(maxRate) forKey:kMaxRateKey];
    [params setObject:@(minAmount) forKey:kMinAmountKey];
    [params setObject:@(maxAmount) forKey:kMaxAmountKey];
    if (reservedAmount)
    {
        [params setObject:reservedAmount forKey:kReservedAmountKey];
    }
    [params setObject:@(repayMethodIndex) forKey:kRepayMethodIndexKey];
    [params setObject:@(minDays) forKey:kMinDaysKey];
    [params setObject:@(maxDays) forKey:kMaxDaysKey];
    [params setObject:@(durType) forKey:kDurTypeKey];
    NSString *tradeId = KSaveAutoInvestInfoTradeId;
    //请求
    return [self requestWithTradeId:tradeId data:params];
}

/*
//开启自动投标
- (NSInteger)doOpenAutoInvestWithMinRate:(NSInteger)minRate maxRate:(NSInteger)maxRate minAmount:(NSInteger)minAmount maxAmount:(NSInteger)maxAmount reservedAmount:(NSInteger)reservedAmount repayMethodIndex:(NSString*)repayMethodIndex minDays:(NSInteger)minDays maxDays:(NSInteger)maxDays durType:(NSInteger)durType
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@(minRate) forKey:kMinRateKey];
    [params setObject:@(maxRate) forKey:kMaxRateKey];
    [params setObject:@(minAmount) forKey:kMinAmountKey];
    [params setObject:@(maxAmount) forKey:kMaxAmountKey];
    [params setObject:@(reservedAmount) forKey:kReservedAmountKey];
    if (repayMethodIndex)
    {
        [params setObject:repayMethodIndex forKey:kRepayMethodIndexKey];
    }
    [params setObject:@(minDays) forKey:kMinDaysKey];
    [params setObject:@(maxDays) forKey:kMaxDaysKey];
    [params setObject:@(durType) forKey:kDurTypeKey];
    NSString *tradeId = KOpenAutoInvestTradeId;
    //请求
    return [self requestWithTradeId:tradeId data:params];
}

//关闭自动投标
- (NSInteger)doCloseAutoInvest
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *tradeId = KCloseAutoInvestTradeId;
    //请求
    return [self requestWithTradeId:tradeId data:params];
}
 */
@end
