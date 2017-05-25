//
//  KSIRItemEntity.m
//  kaisafax
//
//  Created by semny on 16/8/5.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSIRItemEntity.h"

@implementation KSIRItemEntity

+ (NSDictionary *)modelContainerPropertyGenericClass
{
    // value should be Class or Class name.
    return @{@"dueDate" : KSDueDateEntity.class};
}

//判断是否为业主
- (BOOL)isOwner
{
    BOOL flag = (_ownerFee && [self.class isValue1:_ownerFee greaterValue2:@"0"]);
    return flag;
}

//获取状态字符串
-(NSString*)getStatusText
{
    NSString *statusText = nil;
    switch (_status)
    {
        case KSInvestRepayStatusUnRepay:
            statusText = @"未还款";
            break;
        case KSInvestRepayStatusOverdue:
            statusText = @"已逾期";
            break;
        case KSInvestRepayStatusCleared:
            statusText = @"已还清";
            break;
        case KSInvestRepayStatusTransfer:
            statusText = @"已转让";
            break;
        case KSInvestRepayStatusAdvances:
            statusText = @"已垫付";
            break;
        default:
            break;
    }
    return statusText;
}

@end
