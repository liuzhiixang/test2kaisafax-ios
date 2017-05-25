//
//  KSRewardBL.h
//  kaisafax
//
//  Created by semny on 16/8/3.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSRequestBL.h"

/**
 *  @author semny
 *
 *  奖励相关
 */
@interface KSRewardBL : KSRequestBL

/**
 *  @author semny
 *
 *  获取可提取奖励信息（红包）
 *
 *  @return 序列号
 */
//- (NSInteger)doGetValidRewards __deprecated_msg("Method deprecated. 合并到用户账户信息接口[KSUserInfoBL doGetUserAssets]返回报文中的avaliableRewardTotal");

/**
 *  @author semny
 *
 *  获取推广奖励
 *
 *  @return 序列号
 */
//- (NSInteger)doGetCommissionIncome __deprecated_msg("Method deprecated. 合并到用户账户信息接口[KSUserInfoBL doGetUserAssets]返回报文中的avaliableRewardTotal");

/**
 *  @author semny
 *
 *  获取可提取奖励信息（红包+推广）
 *
 *  @return 序列号
 */
//- (NSInteger)doGetValidRewardsForAll;

/**
 *  @author semny
 *
 *  获取可提取奖励信息（现金券+红包+推广 明细）
 *
 *  @return 序列号
 */
- (NSInteger)doGetValidRewardsForDetail;

/**
 *  @author semny
 *
 *  获取可提取奖励信息（红包）
 *
 *  @return 序列号
 */
- (NSInteger)doGetValidRewardsForRed;

/**
 *  @author semny
 *
 *  提取奖励
 *
 *  @return 序列号
 */
- (NSInteger)doTakeRewardCashWith:(NSString *)value;

/**
 *  @author semny
 *
 *  获取用户注册后的红包(注册红包)
 *
 *  @return 序列号
 */
- (NSInteger)doGetRegisterRedpacket;

@end
