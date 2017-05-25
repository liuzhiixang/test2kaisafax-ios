//
//  KSValidRewardItemEntity.h
//  kaisafax
//
//  Created by semny on 17/3/20.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"

//可提取奖励明细单条数据
@interface KSValidRewardItemEntity : KSBaseEntity

//类型(红包，现金券，推广收益)
@property (assign, nonatomic) NSInteger type;
//显示金额
@property (copy, nonatomic) NSString *money;
//显示金额(格式化)
@property (copy, nonatomic) NSString *moneyFormat;
//占比
@property (assign, nonatomic) NSInteger ratio;

@end
