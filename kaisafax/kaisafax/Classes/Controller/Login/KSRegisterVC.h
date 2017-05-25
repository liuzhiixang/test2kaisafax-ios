//
//  KSRegisterVC.h
//  kaisafax
//
//  Created by semny on 16/8/9.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSNVBackVC.h"

/**
 *  @author semny
 *
 *  注册界面
 */
@interface KSRegisterVC : KSNVBackVC

/**
 *  @author semny
 *
 *  用户名或手机号初始化
 *
 *  @param userName 用户名或手机好
 *
 *  @return 登录页面
 */
- (instancetype)initWithUserName:(NSString *)userName verifyCode:(NSString*)verifyCode;

@end
