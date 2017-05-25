//
//  KSResponseEntity.m
//  kaisafax
//
//  Created by semny on 15/7/7.
//  Copyright (c) 2015年 kaisafax. All rights reserved.
//

#import "KSResponseEntity.h"

@implementation KSResponseEntity

- (void)setErrorCode:(NSInteger)errorCode
{
    _errorCode = errorCode;
    
    //默认提供的错误信息
    if (!_errorDescription)
    {
        NSString *errorDescription = [KSResponseEntity errorDescriptionByCode:errorCode];
        _errorDescription = errorDescription;
    }
}

+ (NSString *)errorDescriptionByCode:(NSInteger)errorCode
{
    //生成错误描述信息
    NSString *errorDescription = nil;
    switch (errorCode)
    {
        default:
            break;
    }
    return errorDescription;
}

//生成KSResponseEntity回调值对象
+ (KSResponseEntity*)responseFromTradeId:(NSString *)rid sid:(long long)sid body:(id)body
{
    KSResponseEntity *resp = [[KSResponseEntity alloc] init];
    resp.tradeId = rid;
    resp.sid = sid;
    resp.body = body;
    return resp;
}

@end
