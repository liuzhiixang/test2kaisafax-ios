//
//  KSRewardsEntity.h
//  kaisafax
//
//  Created by semny on 16/8/4.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"
#import "KSRewardItemEntity.h"

/**
 *  @author semny
 *
 *  提取的奖励列表(红包)
 */
@interface KSRewardsEntity : KSBaseEntity

//总记录数
@property (nonatomic, assign) NSInteger recordsTotal;
@property (nonatomic, assign) NSInteger recordsFiltered;
//奖励数组 KSRewardItemEntity
@property (nonatomic, strong) NSArray<KSRewardItemEntity*> * couponList;

@end
