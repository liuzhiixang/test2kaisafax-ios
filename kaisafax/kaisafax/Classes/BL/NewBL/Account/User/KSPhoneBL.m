//
//  KSPhoneBL.m
//  kaisafax
//
//  Created by BeiYu on 2016/11/28.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSPhoneBL.h"

@implementation KSPhoneBL
- (NSInteger)doSetPhoneWithStr:(NSString*)phone mobileCap:(NSString*)cha
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (phone)
    {
        params[kMobileKey] = phone;
    }
    
    if (cha)
    {
        params[kVerifyCodeKey] = cha;

    }
    
    NSString *tradeId = KModifyPhoneTradeId;
    //请求
    return [self requestWithTradeId:tradeId data:params];
}
@end
