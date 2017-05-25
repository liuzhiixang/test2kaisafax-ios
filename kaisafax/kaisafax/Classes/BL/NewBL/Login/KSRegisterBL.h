//
//  KSRegisterBL.h
//  kaisafax
//
//  Created by semny on 16/7/26.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSRequestBL.h"

/**
 *  @author semny
 *
 *  注册相关BL
 */
@interface KSRegisterBL : KSRequestBL

/**
 *  @author semny
 *  注册用户
 *
 *  @param mobile   手机号码
 *  @param password 密码
 *  @param referee  推荐人
 *
 *  @return 序列号
 */
- (NSInteger)doRegisterWith:(NSString *)mobile withPassword:(NSString *)password verifyCode:(NSString*)verifyCode referee:(NSString *)referee;

@end
