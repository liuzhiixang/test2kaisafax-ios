//
//  KSUserInfoEntity.m
//  kaisafax
//
//  Created by semny on 16/7/26.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSUserInfoEntity.h"

@implementation KSUserInfoEntity

+ (NSDictionary *)modelContainerPropertyGenericClass {
    // value should be Class or Class name.
    return @{@"user" : KSUserBaseEntity.class,
             @"chinaPnrAccount": KSPNRAccountEntity.class};
}

@end
