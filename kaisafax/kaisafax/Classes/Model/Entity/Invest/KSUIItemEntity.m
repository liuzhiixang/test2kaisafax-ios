//
//  KSUIItemEntity.m
//  kaisafax
//
//  Created by semny on 16/8/5.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSUIItemEntity.h"

@implementation KSUIItemEntity
+ (NSDictionary *)modelContainerPropertyGenericClass
{
    // value should be Class or Class name.
    return @{@"loan" : KSLoanItemEntity.class,
             @"invest" : KSInvestItemEntity.class};
}
@end
