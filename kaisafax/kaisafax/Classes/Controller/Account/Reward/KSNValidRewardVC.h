//
//  KSNValidRewardVC.h
//  kaisafax
//
//  Created by semny on 17/4/17.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSNVBackVC.h"
#import "KSValidRewardsEntity.h"

//可提取奖励
@interface KSNValidRewardVC : KSNVBackVC

@property (nonatomic,assign) KSWebSourceType type;

//可提取奖励数据
@property (strong, nonatomic) KSValidRewardsEntity *validRewards;

@end
