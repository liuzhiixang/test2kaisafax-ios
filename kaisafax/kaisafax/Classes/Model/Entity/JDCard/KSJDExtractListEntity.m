//
//  KSJDExtractListEntity.m
//  kaisafax
//
//  Created by semny on 17/3/23.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSJDExtractListEntity.h"

@implementation KSJDExtractListEntity

+ (NSDictionary *)modelContainerPropertyGenericClass
{
    // value should be Class or Class name.
    return @{@"data" : KSJDExtractItemEntity.class};
}

@end
