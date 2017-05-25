//
//  KSJDCardExtractBL.m
//  kaisafax
//
//  Created by Jjyo on 2017/3/22.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSJDCardExtractBL.h"

@implementation KSJDCardExtractBL



- (NSInteger)doGetCardWithAmount:(NSInteger)amount
{
    
    //请求
    return [self requestWithTradeId:KGetJDECardTradeId data:@{@"amount" : @(amount)}];
}


@end
