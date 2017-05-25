//
//  KSUserInvestsEntity.m
//  kaisafax
//
//  Created by semny on 16/8/5.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSUserInvestsEntity.h"

@implementation KSUserInvestsEntity
+ (NSDictionary *)modelContainerPropertyGenericClass {
    // value should be Class or Class name.
    return @{@"investList" : KSUIItemEntity.class};
}
@end
