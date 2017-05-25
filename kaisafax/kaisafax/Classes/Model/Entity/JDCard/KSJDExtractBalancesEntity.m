//
//  KSJDExtractBalancesEntity.m
//  kaisafax
//
//  Created by Jjyo on 2017/3/22.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSJDExtractBalancesEntity.h"

@implementation KSJDExtractBalancesEntity


+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"jdAmount" : @"amount"};
}

@end
