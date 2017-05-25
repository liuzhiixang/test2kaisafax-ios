//
//  KSRedPackageEntity.m
//  kaisafax
//
//  Created by semny on 16/8/4.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSRedPackageEntity.h"

@implementation KSRedPackageEntity
/*+ (NSDictionary *)modelContainerPropertyGenericClass
{
    // value should be Class or Class name.
    return @{@"creator": KSRealmEntity.class};
}*/

+ (NSDictionary *)modelCustomPropertyMapper
{
    return @{@"rpId" : @"id"};
}

// 当 JSON 转为 Model 完成后，该方法会被调用。
// 你可以在这里对数据进行校验，如果校验不通过，可以返回 NO，则该 Model 会被忽略。
// 你也可以在这里做一些自动转换不能完成的工作。
/*
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    NSNumber *expiredTime = dic[@"expiredTime"];
    NSNumber *availableTime = dic[@"availableTime"];
    NSNumber *recordTime = dic[@"recordTime"];
    
    //if (![expiredTime isKindOfClass:[NSNumber class]] || ![availableTime isKindOfClass:[NSNumber class]] || ![recordTime isKindOfClass:[NSNumber class]]) return NO;
    if(expiredTime && [expiredTime isKindOfClass:[NSNumber class]])
    {
        _expiredTime = [KSBaseEntity dateWithIntervalTime:expiredTime.longLongValue];
    }
    if(availableTime && [availableTime isKindOfClass:[NSNumber class]])
    {
        _availableTime = [KSBaseEntity dateWithIntervalTime:availableTime.longLongValue];
    }
    if(recordTime && [recordTime isKindOfClass:[NSNumber class]])
    {
        _recordTime = [KSBaseEntity dateWithIntervalTime:recordTime.longLongValue];
    }
    return YES;
}
*/
// 当 Model 转为 JSON 完成后，该方法会被调用。
// 你可以在这里对数据进行校验，如果校验不通过，可以返回 NO，则该 Model 会被忽略。
// 你也可以在这里做一些自动转换不能完成的工作。
/*
- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic
{
    //if (!_expiredTime || !_availableTime || !_recordTime) return NO;
    
    if(_expiredTime && [_expiredTime isKindOfClass:[NSDate class]])
    {
        long long expiredTime = _expiredTime.timeIntervalSince1970*1000;
        dic[@"expiredTime"] = @(expiredTime);
    }
    if(_availableTime && [_availableTime isKindOfClass:[NSDate class]])
    {
        long long availableTime = _availableTime.timeIntervalSince1970*1000;
        dic[@"availableTime"] = @(availableTime);
    }
    if(_recordTime && [_recordTime isKindOfClass:[NSDate class]])
    {
        long long recordTime = _recordTime.timeIntervalSince1970*1000;
        dic[@"recordTime"] = @(recordTime);
    }
    return YES;
}
*/
@end
