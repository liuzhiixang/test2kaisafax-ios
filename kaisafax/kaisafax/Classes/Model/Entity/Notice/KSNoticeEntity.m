//
//  KSNoticeEntity.m
//  kaisafax
//
//  Created by semny on 16/8/1.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSNoticeEntity.h"

@implementation KSNoticeEntity

+ (NSDictionary *)modelContainerPropertyGenericClass {
    // value should be Class or Class name.
    return @{@"noticeList" : [KSNoticeItemEntity class]};
}

//+ (NSDictionary *)modelCustomPropertyMapper {
//    return @{@"more" : @"more",
//             @"platformType" : @"platformType",
//             @"appChannels" : @"appChannels",
//             @"list" : @"list",
//             @"appVersions" : @"appVersions",
//             @"status" : @"status"};
//}

@end
