//
//  KSConfirmVCViewController.h
//  kaisafax
//
//  Created by semny on 16/8/11.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSNVBackVC.h"
#import "KSVerifyCodeBL.h"


/**
 *  @author semny
 *
 *  注册过程校验验证码
 */
@interface KSConfirmVC : KSNVBackVC

/**
 *  @author semny
 *
 *  用户名或手机号初始化
 *
 *  @param userName 用户名或手机好
 *  @param type     流程类型
 *
 *  @return 手机验证码校验界面
 */
- (instancetype)initWithUserName:(NSString *)userName type:(KSVerifyProcessType)type;

@end
