//
//  KSInvestAutoInfoEntity.m
//  kaisafax
//
//  Created by semny on 16/11/23.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSInvestAutoInfoEntity.h"

@implementation KSInvestAutoInfoEntity

+ (NSDictionary *)modelContainerPropertyGenericClass
{
    // value should be Class or Class name.
    return @{@"autoInvest" : KSInvestAutoConfigEntity.class};
}

@end
