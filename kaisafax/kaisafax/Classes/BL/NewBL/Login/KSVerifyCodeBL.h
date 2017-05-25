//
//  KSVerifyCodeBL.h
//  kaisafax
//
//  Created by semny on 16/7/26.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSRequestBL.h"

//0:register 注册，1:resetPassword 忘记密码，2:oldMobile 原手机验证，3:newMobile 新手机号验证
//验证码流程类型
typedef NS_ENUM(NSInteger,KSVerifyProcessType)
{
    KSVerifyProcessTypeRegister = 0,            //注册中的验证码
    KSVerifyProcessTypeReSetPassword = 1,       //设置密码
    KSVerifyProcessTypeVerPhone = 2,            //认证手机号
};

/**
 *  @author semny
 *
 *  验证码相关的接口BL
 */
@interface KSVerifyCodeBL : KSRequestBL

@property (nonatomic, assign, readonly) KSVerifyProcessType type;

/**
 *  @author semny
 *
 *  验证码BL
 *
 *  @param type 流程类型
 *
 *  @return 验证码BL
 */
- (instancetype)initWithType:(KSVerifyProcessType)type;

/**
 *  @author semny
 *
 *  获取手机短信验证码
 *
 *  @param mobileNo 接收验证码短信的手机号
 *
 *  @return 序列号
 */
- (NSInteger)doGetSMSVerifyCode:(NSString *)mobileNo;

/**
 *  @author semny
 *  重设密码时，检测验证码是否正确
 *
 *  @param verifyCode 验证码
 *  @param mobileNo   手机号码
 *
 *  @return 序列号
 */
- (NSInteger)doCheckVerifyCode:(NSString *)verifyCode mobileNo:(NSString *)mobileNo;
@end
