//
//  KSValidRewardsEntity.h
//  kaisafax
//
//  Created by semny on 17/3/20.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"
#import "KSValidRewardItemEntity.h"

//可提取奖励的明细实体

@interface KSValidRewardsEntity : KSBaseEntity

//提取说明
@property (strong, nonatomic) NSArray *explainList;
//可提取总计金额
@property (copy, nonatomic) NSString *totalExtractableAmt;
/*
//可提取总计金额(格式化)
@property (copy, nonatomic) NSString *totalExtractableAmtFormat;

//可提取金额明细
@property (strong, nonatomic) NSArray<KSValidRewardItemEntity*> *dataRatioArray;
*/
@end
