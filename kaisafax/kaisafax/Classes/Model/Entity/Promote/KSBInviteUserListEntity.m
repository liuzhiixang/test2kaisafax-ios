//
//  KSBInviteUserListEntity.m
//  kaisafax
//
//  Created by semny on 16/9/7.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBInviteUserListEntity.h"

@implementation KSBInviteUserListEntity

+ (NSDictionary *)modelContainerPropertyGenericClass {
    // value should be Class or Class name.
    return @{@"dataList" : KSInviteUserEntity.class};
}

@end
