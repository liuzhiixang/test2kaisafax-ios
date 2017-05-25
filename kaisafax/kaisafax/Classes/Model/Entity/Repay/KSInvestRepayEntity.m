//
//  KSInvestRepayEntity.m
//  kaisafax
//
//  Created by semny on 16/8/5.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSInvestRepayEntity.h"

@implementation KSInvestRepayEntity

+ (NSDictionary *)modelContainerPropertyGenericClass
{
    // value should be Class or Class name.
    return @{@"repayList" : KSIRItemEntity.class};
}

@end
