//
//  KSContactBL.m
//  kaisafax
//
//  Created by BeiYu on 2016/11/24.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSContactBL.h"

@implementation KSContactBL
- (NSInteger)doSetContactWithName:(NSString*)name mobile:(NSString*)mobile relation:(NSInteger)relation
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    params[kNameKey] = name;
    params[kMobileKey] = mobile;
    params[kRelationKey] = @(relation);

    NSString *tradeId = KModifyContactor;
    
    return [self requestWithTradeId:tradeId data:params];
}
@end
