//
//  KSRulesEntity.h
//  kaisafax
//
//  Created by yubei on 2017/4/20.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"

@interface KSRulesEntity : KSBaseEntity
//最小投资金额
@property (nonatomic, assign) NSInteger minAmount;
//最大投资金额
@property (nonatomic, assign) NSInteger maxAmount;
//投资递增金额
@property (nonatomic, assign) NSInteger stepAmount;
@end
