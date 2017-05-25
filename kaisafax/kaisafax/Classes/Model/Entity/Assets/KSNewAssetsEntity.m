//
//  KSNewAssetsEntity.m
//  kaisafax
//
//  Created by semny on 17/3/22.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSNewAssetsEntity.h"

@implementation KSNewAssetsEntity

+ (NSDictionary *)modelContainerPropertyGenericClass {
    // value should be Class or Class name.
    return @{@"fund" : KSNewFundEntity.class,
             //@"user" : KSUserBaseEntity.class,
             //@"account" : KSThirdPartyEntity.class
             };
}

//- (BOOL)isAccountNull
//{
//    return (!_account.usrCustId || _account.usrCustId.length<=0);
//}

- (NSString *)totalAssetFormat
{
    if (!_totalAsset || _totalAsset.length <= 0)
    {
        _totalAssetFormat = @"0.00";
        return _totalAssetFormat;
    }
    else if (_totalAssetFormat)
    {
        return _totalAssetFormat;
    }
    //格式化万元
    _totalAssetFormat = [self.class formatTenThousandAmountString:_totalAsset];
    return _totalAssetFormat;
}


@end
