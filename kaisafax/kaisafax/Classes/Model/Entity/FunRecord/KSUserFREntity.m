//
//  KSUserFREntity.m
//  kaisafax
//
//  Created by semny on 16/8/3.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSUserFREntity.h"

@implementation KSUserFREntity
+ (NSDictionary *)modelContainerPropertyGenericClass {
    // value should be Class or Class name.
    return @{@"fundList" : KSUserFRItemEntity.class};
}
@end
