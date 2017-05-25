//
//  KSEmailBL.m
//  kaisafax
//
//  Created by BeiYu on 2016/11/16.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSEmailBL.h"

@implementation KSEmailBL
- (NSInteger)doSetEmailWithStr:(NSString*)mailStr
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (mailStr)
    {
        params[kEmailKey] = mailStr;
    }
    
    NSString *tradeId = KBindEmail;
    //请求
    return [self requestWithTradeId:tradeId data:params];
}
@end
