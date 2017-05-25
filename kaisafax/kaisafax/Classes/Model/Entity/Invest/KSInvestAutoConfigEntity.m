//
//  KSInvestAutoConfigEntity.m
//  kaisafax
//
//  Created by semny on 16/11/23.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSInvestAutoConfigEntity.h"

@implementation KSInvestAutoConfigEntity


//- (NSString *)formatRate:(CGFloat)rate{
//    
//    return [numberFormatter stringFromNumber:@(rate/100)];
//}


- (NSString *)getAutoRateText
{
    return [NSString stringWithFormat:@"%@%% ~ %@%%", [self getMinRateText], [self getMaxRateText]];
}

- (NSString *)getMinRateText
{
    return [NSString stringWithFormat:@"%.2f", _minRate/100.00f];
}
- (NSString *)getMaxRateText
{
    return [NSString stringWithFormat:@"%.2f", _maxRate/100.00f];
}

- (NSString *)getAutoDurationText
{
    return [NSString stringWithFormat:@"%ld ~ %ld", (long)_minDays, (long)_maxDays];
}

- (NSString *)getAutoAmountText
{
    return [NSString stringWithFormat:@"%ld ~ %ld", (long)_minAmount, (long)_maxAmount];
}

- (NSString *)getReservedAmountText
{
    return _reservedAmount;//[NSString stringWithFormat:@"%.2f", _reservedAmount];
}

- (NSString *)getAutoDurationType
{
    if (_durType == KSAutoLoanDurationTypeDay) {
        return @"(天)";
    }
    return @"(月)";
}

- (BOOL)isAutoLoanOpen
{
    return _status == KSAutoLoanStatusActive;
}

- (NSString *)getRangeText
{
    if ([self isAutoLoanOpen]) {
        return [NSString stringWithFormat:@"%ld", (long)_range];
    }
    return @"- -";
}

- (NSArray *)getRepayMethodStringArray
{
    NSMutableArray *repayArray = [NSMutableArray array];
    
    if ((_repayMethodIndex & KSAutoLoanRepayTypeEqualPrincipal) == KSAutoLoanRepayTypeEqualPrincipal)
    {
        [repayArray addObject:@"等额本金"];
    }
    
    if ((_repayMethodIndex & KSAutoLoanRepayTypeEqualInstallment) == KSAutoLoanRepayTypeEqualInstallment)
    {
        [repayArray addObject:@"等额本息"];
    }
    if ((_repayMethodIndex & KSAutoLoanRepayTypeBullet) == KSAutoLoanRepayTypeBullet)
    {
        [repayArray addObject:@"一次性还款"];
    }
    if ((_repayMethodIndex & KSAutoLoanRepayTypeInterest) == KSAutoLoanRepayTypeInterest)
    {
        [repayArray addObject:@"先息后本"];
    }
    return [NSArray arrayWithArray:repayArray];
}

//判断还款类型的选择
- (BOOL)isEQUAL_PRINCIPAL
{
    return (_repayMethodIndex & KSAutoLoanRepayTypeEqualPrincipal) == KSAutoLoanRepayTypeEqualPrincipal;
}

- (BOOL)isEQUAL_INSTALLMENT
{
    return (_repayMethodIndex & KSAutoLoanRepayTypeEqualInstallment) == KSAutoLoanRepayTypeEqualInstallment;
}

- (BOOL)isBULLET_REPAYMENT
{
    return (_repayMethodIndex & KSAutoLoanRepayTypeBullet) == KSAutoLoanRepayTypeBullet;
}

- (BOOL)isINTEREST
{
    return (_repayMethodIndex & KSAutoLoanRepayTypeInterest) == KSAutoLoanRepayTypeInterest;
}
@end
