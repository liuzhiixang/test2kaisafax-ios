//
//  KSPromoteEntity.m
//  kaisafax
//
//  Created by semny on 16/8/4.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSPromoteEntity.h"

@implementation KSPromoteEntity

+ (NSDictionary *)modelContainerPropertyGenericClass {
    // value should be Class or Class name.
    return @{
//             @"qqShare" : KSShareEntity.class,
//             @"wxShare" : KSShareEntity.class,
//             @"wxShareSingle" : KSShareEntity.class,
//             @"weiboShare" : KSShareEntity.class,
            // @"user" : KSUserBaseEntity.class,
             @"shareInfo" : KSShareEntity.class
             };
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"inItCommission" : @"initCommission"};
}
@end
