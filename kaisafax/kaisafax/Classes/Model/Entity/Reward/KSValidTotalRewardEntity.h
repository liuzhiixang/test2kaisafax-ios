//
//  KSValidTotalRewardEntity.h
//  kaisafax
//
//  Created by semny on 16/8/22.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"

/**
 *  @author semny
 *
 *  整合的可提取奖励数据(红包＋推广)
 */
@interface KSValidTotalRewardEntity : KSBaseEntity

//审核金额
@property (nonatomic, assign) CGFloat totalAuditReward;
//可提取奖励
@property (nonatomic, assign) CGFloat totalAvaliableReward;
//规则说明
@property (nonatomic, strong) NSArray *explainList;

@end
