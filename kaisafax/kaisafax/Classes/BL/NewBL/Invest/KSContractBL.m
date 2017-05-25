//
//  KSContractBL.m
//  kaisafax
//
//  Created by semny on 16/11/25.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSContractBL.h"

@implementation KSContractBL

//根据投资id获取合同信息
- (NSInteger)doGetContractWithInvestId:(NSString*)investId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (investId)
    {
        [params setObject:investId forKey:kInvestIdKey];
    }
    NSString *tradeId = KGetInvestContractTradeId;
    //请求
    return [self requestWithTradeId:tradeId data:params];
}

@end
