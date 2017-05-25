//
//  KSORLoanEntity.m
//  kaisafax
//
//  Created by semny on 16/8/1.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSORLoanEntity.h"

@implementation KSORLoanEntity
+ (NSDictionary *)modelContainerPropertyGenericClass {
    // value should be Class or Class name.
    return @{@"ownerLoansData" : KSOwnerLoanItemEntity.class,
             @"recommendData":KSRecommendDataEntity.class};
}

@end
