//
//  KSUserInfoItemModel.m
//  kaisafax
//
//  Created by BeiYu on 16/7/28.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSUserInfoItemModel.h"

@implementation KSUserInfoItemModel

@end






@implementation KSUserInfoSectionModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    // value should be Class or Class name.
    return @{@"rowData" : KSUserInfoItemModel.class};
}

@end
