//
//  KSPersonInfoBL.m
//  kaisafax
//
//  Created by BeiYu on 2016/11/15.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSPersonInfoBL.h"

@implementation KSPersonInfoBL
- (NSInteger)doGetPersonalInfo
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];

    NSString *tradeId = KPersonalInfoTradeId;
    //请求
    return [self requestWithTradeId:tradeId data:params];
}
@end
