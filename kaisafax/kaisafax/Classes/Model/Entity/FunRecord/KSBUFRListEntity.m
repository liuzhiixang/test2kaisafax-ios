//
//  KSBUFRListEntity.m
//  kaisafax
//
//  Created by semny on 16/9/7.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBUFRListEntity.h"

@implementation KSBUFRListEntity
+ (NSDictionary *)modelContainerPropertyGenericClass
{
    return @{@"dataList" : KSUserFRItemEntity.class};
}
@end
