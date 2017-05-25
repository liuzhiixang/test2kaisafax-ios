//
//  KSBusinessEntity.m
//  kaisafax
//
//  Created by semny on 16/8/1.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBusinessEntity.h"

@implementation KSBusinessEntity

+ (NSDictionary *)modelContainerPropertyGenericClass {
    // value should be Class or Class name.
    return @{@"businessList" : [KSBussinessItemEntity class]};
}

//+ (NSDictionary *)modelCustomPropertyMapper {
//    return @{@"recordsFiltered" : @"recordsFiltered",
//             @"recordsTotal" : @"recordsTotal",
//             @"businessData" : @"businessData"};
//}
@end
