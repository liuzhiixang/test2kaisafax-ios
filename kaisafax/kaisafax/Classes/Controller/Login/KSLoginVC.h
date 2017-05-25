//
//  KSLoginVC.h
//  kaisafax
//
//  Created by semny on 16/8/8.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSNVBaseVC.h"

@interface KSLoginVC : KSNVBaseVC

/**
 *  @author semny
 *
 *  用户名或手机号初始化
 *
 *  @param userName 用户名或手机好
 *
 *  @return 登录页面
 */
- (instancetype)initWithUserName:(NSString *)userName;

@end
