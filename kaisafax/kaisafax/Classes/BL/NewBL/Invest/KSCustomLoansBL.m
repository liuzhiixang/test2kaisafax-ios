//
//  KSCustomLoansBL.m
//  kaisafax
//
//  Created by semny on 16/12/22.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSCustomLoansBL.h"

@implementation KSCustomLoansBL

// 定制标列表
- (NSInteger)doGetCustomLoans
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *tradeId = KCustomLoansTradeId;
    //请求
    return [self requestWithTradeId:tradeId data:params];
}

@end
