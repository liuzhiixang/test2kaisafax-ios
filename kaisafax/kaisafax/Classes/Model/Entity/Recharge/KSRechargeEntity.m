//
//  KSRechargeEntity.m
//  kaisafax
//
//  Created by semny on 16/8/10.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSRechargeEntity.h"

@implementation KSRechargeEntity

+ (NSDictionary *)modelContainerPropertyGenericClass
{
    // value should be Class or Class name.
    return @{@"bank" : KSBankEntity.class,
             @"expressCard" : KSCardItemEntity.class/*,
             @"account" : KSThirdPartyEntity.class*/};
}

@end
