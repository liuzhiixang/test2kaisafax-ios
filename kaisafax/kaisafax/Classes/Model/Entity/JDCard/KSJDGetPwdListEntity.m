//
//  KSJDGetPwdListEntity.m
//  kaisafax
//
//  Created by mac on 17/3/24.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSJDGetPwdListEntity.h"

@implementation KSJDGetPwdListEntity

+ (NSDictionary *)modelContainerPropertyGenericClass
{
    // value should be Class or Class name.
    return @{@"data" : KSJDExtractItemEntity.class};
}


@end
