//
//  KSInvestRecordItemEntity.m
//  kaisafax
//
//  Created by semny on 16/8/2.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSInvestRecordItemEntity.h"

@implementation KSInvestRecordItemEntity


// 当 JSON 转为 Model 完成后，该方法会被调用。
// 你可以在这里对数据进行校验，如果校验不通过，可以返回 NO，则该 Model 会被忽略。
// 你也可以在这里做一些自动转换不能完成的工作。
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    NSNumber *investTime = dic[@"investTime"];
    
    //    if (![investTime isKindOfClass:[NSNumber class]]) return NO;
    if(investTime && [investTime isKindOfClass:[NSNumber class]])
    {
        _investTime = [KSBaseEntity dateWithIntervalTime:investTime.longLongValue];
    }
    return YES;
}

// 当 Model 转为 JSON 完成后，该方法会被调用。
// 你可以在这里对数据进行校验，如果校验不通过，可以返回 NO，则该 Model 会被忽略。
// 你也可以在这里做一些自动转换不能完成的工作。
- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic
{
    //if (!_investTime) return NO;
    if(_investTime && [_investTime isKindOfClass:[NSDate class]])
    {
        long long investTime = _investTime.timeIntervalSince1970*1000;
        dic[@"investTime"] = @(investTime);
    }
    return YES;
}

@end
