//
//  KSValidRewardItemEntity.m
//  kaisafax
//
//  Created by semny on 17/3/20.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSValidRewardItemEntity.h"

/**
 可提取金额明细的单条数据实体
 */
@implementation KSValidRewardItemEntity

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
    _moneyFormat = [NSString stringWithFormat:@"%@%@",[self.class formatAmountString:_money], KUnit];//[self.class formatAmountString:_money];
    return _moneyFormat;
}

@end
