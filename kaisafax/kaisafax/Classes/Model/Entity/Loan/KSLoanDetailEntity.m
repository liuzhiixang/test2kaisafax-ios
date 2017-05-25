//
//  KSLoanDetailEntity.m
//  kaisafax
//
//  Created by semny on 16/8/2.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSLoanDetailEntity.h"

@implementation KSLoanDetailEntity

+ (NSDictionary *)modelContainerPropertyGenericClass {
    // value should be Class or Class name.
    return @{@"loan" : [KSLoanItemEntity class]};
}

@end
