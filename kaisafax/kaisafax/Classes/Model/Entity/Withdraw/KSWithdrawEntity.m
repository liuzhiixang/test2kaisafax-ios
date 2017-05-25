//
//  KSWithdrawEntity.m
//  kaisafax
//
//  Created by semny on 16/8/19.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSWithdrawEntity.h"

@implementation KSWithdrawEntity

+ (NSDictionary *)modelContainerPropertyGenericClass
{
    // value should be Class or Class name.
    return @{@"bank" : KSBankEntity.class,
             @"bankCard" : KSCardItemEntity.class,
             @"typeList" : KSWithdrawTypeEntity.class};
}

@end
