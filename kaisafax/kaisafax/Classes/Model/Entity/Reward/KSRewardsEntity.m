//
//  KSRewardsEntity.m
//  kaisafax
//
//  Created by semny on 16/8/4.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSRewardsEntity.h"

@implementation KSRewardsEntity
+ (NSDictionary *)modelContainerPropertyGenericClass
{
    // value should be Class or Class name.
    return @{@"data" : KSRewardItemEntity.class};
}
@end
