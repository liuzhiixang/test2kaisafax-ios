//
//  KSHomeTogetherEntity.m
//  kaisafax
//
//  Created by semny on 16/8/1.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSHomeTogetherEntity.h"

@implementation KSHomeTogetherEntity
+ (NSDictionary *)modelContainerPropertyGenericClass {
    // value should be Class or Class name.
    return @{@"noticeResult" : KSBussinessItemEntity.class,
             @"bannerResult" : KSBussinessItemEntity.class,
             @"bannerResult" : KSNoticeEntity.class };
}
@end
