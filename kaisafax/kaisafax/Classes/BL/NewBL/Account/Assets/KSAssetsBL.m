//
//  KSAssetsBL.m
//  kaisafax
//
//  Created by semny on 17/3/22.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSAssetsBL.h"

@implementation KSAssetsBL
/**
 *  @author semny
 *
 *  获取当前用户的个人账户财富信息
 *
 *  @return 序列号
 */
- (NSInteger)doGetUserNewAssets
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *tradeId = KUserNewAssetsTradeId;
    //请求
    return [self requestWithTradeId:tradeId data:params];
}

/**
 *  @author semny
 *
 *  获取当前用户的个人账户财富信息
 *
 *  @param delegate 网络请求delegate
 *
 *  @return 序列号
 */
- (NSInteger)doGetUserNewAssetsByDelegate:(id<SQRequestDelegate>)delegate
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *tradeId = KUserNewAssetsTradeId;
    //请求
    return [self requestWithTradeId:tradeId data:params delegate:delegate];
}

/**
 *  @author semny
 *
 *  获取当前用户的累积收益
 *
 *  @return 序列号
 */
- (NSInteger)doGetUserAccumulatedIncome
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *tradeId = KGetUserAccumulatedIncomeTradeId;
    //请求
    return [self requestWithTradeId:tradeId data:params];
}

@end
