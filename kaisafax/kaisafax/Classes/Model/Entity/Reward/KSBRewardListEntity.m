//
//  KSBRewardListEntity.m
//  kaisafax
//
//  Created by semny on 16/9/7.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBRewardListEntity.h"

@implementation KSBRewardListEntity
+ (NSDictionary *)modelContainerPropertyGenericClass
{
    // value should be Class or Class name.
    return @{@"dataList" : KSRewardItemEntity.class};
}
@end
