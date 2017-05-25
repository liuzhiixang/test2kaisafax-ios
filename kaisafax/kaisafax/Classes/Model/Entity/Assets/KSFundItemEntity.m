//
//  KSFundItemEntity.m
//  kaisafax
//
//  Created by semny on 17/3/22.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSFundItemEntity.h"

@implementation KSFundItemEntity


- (NSString *)moneyFormat
{
    if (!_money || _money.length <= 0)
    {
        _moneyFormat = @"0.00";
        return _moneyFormat;
    }
    else if (_moneyFormat)
    {
        return _moneyFormat;
    }
    //格式化万元
    _moneyFormat = [NSString stringWithFormat:@"%@%@",[self.class formatAmountString:_money], KUnit];
    return _moneyFormat;
}

@end
