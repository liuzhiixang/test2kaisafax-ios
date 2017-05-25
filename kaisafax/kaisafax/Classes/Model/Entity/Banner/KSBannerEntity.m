//
//  KSBannerEntity.m
//  kaisafax
//
//  Created by semny on 16/8/1.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBannerEntity.h"

@implementation KSBannerEntity
+ (NSDictionary *)modelContainerPropertyGenericClass {
    // value should be Class or Class name.
    return @{@"bannerList" : [KSBussinessItemEntity class]};
}

//+ (NSDictionary *)modelCustomPropertyMapper {
//    return @{@"bannerList" : @"bannerList"};
//}
@end

