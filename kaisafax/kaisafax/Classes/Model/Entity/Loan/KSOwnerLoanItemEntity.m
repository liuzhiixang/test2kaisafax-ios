//
//  KSOwnerLoanItemEntity.m
//  kaisafax
//
//  Created by semny on 16/8/1.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSOwnerLoanItemEntity.h"
#import "KSDurationEntity.h"

@implementation KSOwnerLoanItemEntity
+ (NSDictionary *)modelContainerPropertyGenericClass
{
    return @{@"freeDuration" : KSDurationEntity.class,
            @"loan" : KSLoanItemEntity.class };
}


//免费的期限
- (NSString *)getFreeText
{
    KSUnitType unitype = _freeDuration.unitType;
    if (unitype == KSUnitYear) {
        return [NSString stringWithFormat:@"免%ld年物业费", (long)_freeDuration.value];
    }else if (unitype == KSUnitMonth){
        return [NSString stringWithFormat:@"免%ld个月物业费", (long)_freeDuration.value];
    }
    return [NSString stringWithFormat:@"免%ld天物业费", (long)_freeDuration.value];
}
@end
