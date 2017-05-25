//
//  KSInviteUserEntity.m
//  kaisafax
//
//  Created by semny on 16/8/23.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSInviteUserEntity.h"

@implementation KSInviteUserEntity

- (NSString *)getInvestStatus
{
    if (_isFirstInvest ==  true)
    {
        return @"已投资";
    }
    return @"未投资";
}
@end
