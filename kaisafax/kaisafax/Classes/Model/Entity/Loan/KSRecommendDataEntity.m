//
//  KSRecommendDataEntity.m
//  kaisafax
//
//  Created by yubei on 2017/4/25.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSRecommendDataEntity.h"
#import "KSLoanItemEntity.h"

@implementation KSRecommendDataEntity
+ (NSDictionary *)modelContainerPropertyGenericClass
{
    return @{@"recommendList" : KSLoanItemEntity.class};
}
@end
