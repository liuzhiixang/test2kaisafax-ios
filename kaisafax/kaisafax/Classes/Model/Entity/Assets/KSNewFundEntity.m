//
//  KSNewFundEntity.m
//  kaisafax
//
//  Created by semny on 17/3/22.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSNewFundEntity.h"

@implementation KSNewFundEntity
+ (NSDictionary *)modelContainerPropertyGenericClass {
    // value should be Class or Class name.
    return @{@"fund" : KSFundItemEntity.class,
             @"accrual" : KSFundItemEntity.class,
             @"available" : KSFundItemEntity.class,
             @"frozen" : KSFundItemEntity.class};
}
@end
