//
//  KSJDProvideListEntity.m
//  kaisafax
//
//  Created by okline.kwan on 17/3/22.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSJDProvideListEntity.h"

@implementation KSJDProvideListEntity

+ (NSDictionary *)modelContainerPropertyGenericClass {
    // value should be Class or Class name.
    return @{@"list" : KSJDRecordItemEntity.class};
}



@end
