//
//  KSJDCardActionBL.m
//  kaisafax
//
//  Created by semny on 17/3/23.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSJDCardActionBL.h"

@implementation KSJDCardActionBL
//获取卡密(挂卡)
- (NSInteger)doGetJDCardPasswordWithCardId:(long long)cardId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *tradeId = KGetJDPwdTradeId;
    [params setObject:@(cardId) forKey:kIdKey];
    //请求
    return [self requestWithTradeId:tradeId data:params];
}

//获取卡密(发送短信,默认制卡的手机号)
- (NSInteger)doSendMobileCaptchaForJDCard
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *tradeId = KSendMobileCaptchaForJDTradeId;
    //请求
    return [self requestWithTradeId:tradeId data:params];
}

//获取卡密(验证短信)
- (NSInteger)doGetJDCardPasswordWithCaptcha:(NSString*)Captcha cardId:(long long)cardId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *tradeId = KGetJDDetailTradeId;
    if (Captcha)
    {
        [params setObject:Captcha forKey:kVerifyCodeKey];
    }
    
    [params setObject:@(cardId) forKey:kIdKey];
    //请求
    return [self requestWithTradeId:tradeId data:params];
}

@end
