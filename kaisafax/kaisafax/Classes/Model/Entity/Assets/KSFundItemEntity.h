//
//  KSFundItemEntity.h
//  kaisafax
//
//  Created by semny on 17/3/22.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"

//资产单条数据
@interface KSFundItemEntity : KSBaseEntity

//显示金额
@property (copy, nonatomic) NSString *money;
//显示金额(格式化)
@property (copy, nonatomic) NSString *moneyFormat;
//占比
@property (assign, nonatomic) NSInteger ratio;

@end
