//
//  KSValidRewardsEntity.m
//  kaisafax
//
//  Created by semny on 17/3/20.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSValidRewardsEntity.h"

@implementation KSValidRewardsEntity

+ (NSDictionary *)modelContainerPropertyGenericClass
{
    // value should be Class or Class name.
    return @{@"dataRatioArray" : KSValidRewardItemEntity.class};
}
/*
- (NSString *)totalExtractableAmtFormat
{
    if (!_totalExtractableAmt || _totalExtractableAmt.length <= 0)
    {
        _totalExtractableAmtFormat = @"0.00";
        return _totalExtractableAmtFormat;
    }
    else if (_totalExtractableAmtFormat)
    {
        return _totalExtractableAmtFormat;
    }
    //格式化万元
    _totalExtractableAmtFormat = [KSBaseEntity formatTenThousandAmountString:_totalExtractableAmt];
    return _totalExtractableAmtFormat;
}
*/
@end
