//
//  KSBankBL.m
//  kaisafax
//
//  Created by semny on 16/8/16.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBankBL.h"
#import "KSUserMgr.h"

//快捷
#define KBankListQuickPayKey @"QP"
//网银
#define KBankListInternetBankKey @"B2C"

@implementation KSBankBL

/**
 *  @author semny
 *
 *  获取银行列表(充值等操作中用到的获取支持的银行信息)
 *
 *  @param type 列表类型(QP:快捷支付,B2C:网银支付)
 *
 *  @return 序列号
 */
- (NSInteger)doGetBankListWith:(KSBankListType)type
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    //银行列表类型请求字段
    NSNumber *bankType = @(type);
    [params setObject:bankType forKey:kBankTypeKey];
    NSString *tradeId = KGetBankListTradeId;
    //请求
    return [self requestWithTradeId:tradeId data:params];
}

@end
