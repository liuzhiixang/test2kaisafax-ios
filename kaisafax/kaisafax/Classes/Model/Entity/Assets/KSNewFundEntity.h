//
//  KSNewFundEntity.h
//  kaisafax
//
//  Created by semny on 17/3/22.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"
#import "KSFundItemEntity.h"

//资金相关数据实体
@interface KSNewFundEntity : KSBaseEntity
//待收利息
@property (nonatomic, strong) KSFundItemEntity *accrual;
//待收本金
@property (nonatomic, strong) KSFundItemEntity *fund;
//可用余额
@property (nonatomic, strong) KSFundItemEntity *available;
//冻结金额
@property (nonatomic, strong) KSFundItemEntity *frozen;

@end
