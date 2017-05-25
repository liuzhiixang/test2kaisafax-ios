//
//  KSNewBeeBL.m
//  kaisafax
//
//  Created by semny on 16/9/19.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSNewBeeBL.h"

@implementation KSNewBeeBL

- (NSInteger)doGetNewBeeDetail
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *tradeId = KInvestNewBeeTradeId;
    //请求
    return [self requestWithTradeId:tradeId data:params];
}

@end
