//
//  KSVerifyCodeBL.m
//  kaisafax
//
//  Created by semny on 16/7/26.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSVerifyCodeBL.h"
#import "KSUserMgr.h"

//注册
#define KSVerifyProcessTypeKeyRegister  @"register"
//找回密码
#define KSVerifyProcessTypeKeySetPassword @"resetPassword"
//手机认证
#define KSVerifyProcessTypeKeyVerPhone @"newMobile"

@interface KSVerifyCodeBL()

//@property (nonatomic, assign) KSVerifyProcessType type;
//@property (nonatomic, copy) NSString *typeStr;

@end

@implementation KSVerifyCodeBL

- (instancetype)initWithType:(KSVerifyProcessType)type
{
    self = [super init];
    if (self)
    {
        _type = type;
    }
    return self;
}

#pragma mark - Request

- (NSInteger)doGetSMSVerifyCode:(NSString *)mobileNo
{
    return [self doGetSMSVerifyCode:mobileNo type:self.type];
}

//获取手机短信验证码
- (NSInteger)doGetSMSVerifyCode:(NSString *)mobileNo type:(NSInteger)type
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (mobileNo)
    {
        [params setObject:mobileNo forKey:kMobileKey];
    }
    if (type>-1)
    {
        [params setObject:@(type) forKey:kTypeKey];
    }
    NSString *tradeId = kSendVerifiyCodeTradeId;
    //请求
    return [self requestWithTradeId:tradeId data:params];
}

- (NSInteger)doCheckVerifyCode:(NSString *)verifyCode mobileNo:(NSString *)mobileNo
{
    return [self doCheckVerifyCode:verifyCode mobileNo:mobileNo type:self.type];
}

//重设密码时，检测验证码是否正确
- (NSInteger)doCheckVerifyCode:(NSString *)verifyCode mobileNo:(NSString *)mobileNo type:(NSInteger)type
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (mobileNo)
    {
        [params setObject:mobileNo forKey:kMobileKey];
    }
    if (verifyCode)
    {
        [params setObject:verifyCode forKey:kVerifyCodeKey];
    }
    if (type)
    {
        [params setObject:@(type) forKey:kTypeKey];
    }
    NSString *tradeId = kValideVerifiyCodeTradeId;
    //请求
    return [self requestWithTradeId:tradeId data:params];
}

#pragma mark - Response

@end
