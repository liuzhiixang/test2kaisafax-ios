//
//  KSUserInfoBL.h
//  kaisafax
//
//  Created by semny on 16/7/28.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSRequestBL.h"

/**
 *  @author semny
 *
 *  获取用户相关信息
 */
@interface KSUserInfoBL : KSRequestBL

///**
// *  @author semny
// *
// *  获取当前用户的个人账户财富信息
// *
// *  @return 序列号
// */
//- (NSInteger)doGetUserAssets;
//
///**
// *  @author semny
// *
// *  获取当前用户的个人账户财富信息
// *
// *  @param delegate 网络请求delegate
// *
// *  @return 序列号
// */
//- (NSInteger)doGetUserAssetsByDelegate:(id<SQRequestDelegate>)delegate;

/**
 *  @author semny
 *
 *  获取当前用户的交易记录
 *
 *  @return 序列号
 */
//- (NSInteger)doGetUserInvestRecord;

/**
 *  @author semny
 *
 *  修改用户密码
 *
 *  @return 序列号
 */
- (NSInteger)doModifyUserPassword:(NSString *)oldPW newPW:(NSString *)newPW;

/**
 *  @author semny
 *
 *  忘记密码后修改用户密码
 *
 *  @return 序列号
 */
- (NSInteger)doForgotUserPassword:(NSString *)newPW mobile:(NSString *)mobile verifyCode:(NSString*)verifyCode;

//同步用户信息到本地
- (NSInteger)doSyncUserInfo;
@end
