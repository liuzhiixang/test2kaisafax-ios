//
//  KSRegRedPackEntity.m
//  kaisafax
//
//  Created by semny on 16/8/8.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSRegRedPackEntity.h"

@implementation KSRegRedPackEntity

+ (NSDictionary *)modelContainerPropertyGenericClass
{
    // value should be Class or Class name.
    return @{@"result" : KSRewardItemEntity.class};
}

@end
