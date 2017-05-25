//
//  KSAdvertEntity.m
//  kaisafax
//
//  Created by yubei on 2017/5/3.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSAdvertEntity.h"

@implementation KSAdvertEntity
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"businessData" : [KSBussinessItemEntity class]};
}

@end
