//
//  KSAreaBL.m
//  kaisafax
//
//  Created by BeiYu on 2016/11/22.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSAreaBL.h"

@implementation KSAreaBL
- (NSInteger)doGetArea
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    NSString *tradeId = KGetArea;
    //请求
    return [self requestWithTradeId:tradeId data:params];
}
@end
