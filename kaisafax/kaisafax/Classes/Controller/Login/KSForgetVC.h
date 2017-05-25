//
//  KSForgetVC.h
//  kaisafax
//
//  Created by semny on 16/8/9.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSNVBackVC.h"

/**
 *  @author semny
 *
 *  忘记密码，修改密码界面
 */
@interface KSForgetVC : KSNVBackVC
/**
 *  @author semny
 *
 *  用户名或手机号初始化
 *
 *  @param userName 用户名或手机号
 *
 *  @return 忘记密码，修改密码界面
 */
- (instancetype)initWithUserName:(NSString *)userName verifyCode:(NSString*)verifyCode;

@end
