//
//  KSRewardItemEntity.m
//  kaisafax
//
//  Created by semny on 16/8/4.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSRewardItemEntity.h"

@implementation KSRewardItemEntity

+ (NSDictionary *)modelContainerPropertyGenericClass
{
    // value should be Class or Class name.
    return @{@"pack" : KSRedPackageEntity.class,
             @"target": KSRealmEntity.class
             };
}

+ (NSDictionary *)modelCustomPropertyMapper
{
    return @{@"rId" : @"id"};
}


// 当 JSON 转为 Model 完成后，该方法会被调用。
// 你可以在这里对数据进行校验，如果校验不通过，可以返回 NO，则该 Model 会被忽略。
// 你也可以在这里做一些自动转换不能完成的工作。
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic
{
    NSNumber *allocatedTime = dic[@"allocatedTime"];
    NSNumber *invokedTime = dic[@"invokedTime"];
    NSNumber *consumedTime = dic[@"consumedTime"];
    NSNumber *expiredTime = dic[@"expiredTime"];
    NSNumber *withdrawTime = dic[@"withdrawTime"];
    NSNumber *recordTime = dic[@"recordTime"];
    
    //校验数据是不是存在(需要判断数据是否异常才需要处理)
    //if (![allocatedTime isKindOfClass:[NSNumber class]] || ![invokedTime isKindOfClass:[NSNumber class]] || ![consumedTime isKindOfClass:[NSNumber class]] || ![expiredTime isKindOfClass:[NSNumber class]] || ![withdrawTime isKindOfClass:[NSNumber class]]![recordTime isKindOfClass:[NSNumber class]]) return NO;
    if(allocatedTime && [allocatedTime isKindOfClass:[NSNumber class]])
    {
        _allocatedTime = [KSBaseEntity dateWithIntervalTime:allocatedTime.longLongValue];
    }
    if(invokedTime && [invokedTime isKindOfClass:[NSNumber class]])
    {
        _invokedTime = [KSBaseEntity dateWithIntervalTime:invokedTime.longLongValue];
    }
    if(consumedTime && [consumedTime isKindOfClass:[NSNumber class]])
    {
        _consumedTime = [KSBaseEntity dateWithIntervalTime:consumedTime.longLongValue];
    }
    if(expiredTime && [expiredTime isKindOfClass:[NSNumber class]])
    {
        _expiredTime = [KSBaseEntity dateWithIntervalTime:expiredTime.longLongValue];
    }
    if(withdrawTime && [withdrawTime isKindOfClass:[NSNumber class]])
    {
        _withdrawTime = [KSBaseEntity dateWithIntervalTime:withdrawTime.longLongValue];
    }
    if(recordTime && [recordTime isKindOfClass:[NSNumber class]])
    {
        recordTime = [KSBaseEntity dateWithIntervalTime:recordTime.longLongValue];
    }
    return YES;
}

// 当 Model 转为 JSON 完成后，该方法会被调用。
// 你可以在这里对数据进行校验，如果校验不通过，可以返回 NO，则该 Model 会被忽略。
// 你也可以在这里做一些自动转换不能完成的工作。
- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic
{
    //校验数据是不是存在(需要判断数据是否异常才需要处理)
    //if (!_allocatedTime || !_invokedTime || !_consumedTime || !_expiredTime || !_withdrawTime || !_recordTime) return NO;
    if(_allocatedTime && [_allocatedTime isKindOfClass:[NSDate class]])
    {
        long long allocatedTime = _allocatedTime.timeIntervalSince1970*1000;
        dic[@"allocatedTime"] = @(allocatedTime);
    }
    if(_invokedTime && [_invokedTime isKindOfClass:[NSDate class]])
    {
        long long invokedTime = _invokedTime.timeIntervalSince1970*1000;
        dic[@"invokedTime"] = @(invokedTime);
    }
    if(_consumedTime && [_consumedTime isKindOfClass:[NSDate class]])
    {
        long long consumedTime = _consumedTime.timeIntervalSince1970*1000;
        dic[@"consumedTime"] = @(consumedTime);
    }
    if(_expiredTime && [_expiredTime isKindOfClass:[NSDate class]])
    {
        long long expiredTime = _expiredTime.timeIntervalSince1970*1000;
        dic[@"expiredTime"] = @(expiredTime);
    }
    if(_withdrawTime && [_withdrawTime isKindOfClass:[NSDate class]])
    {
        long long withdrawTime = _withdrawTime.timeIntervalSince1970*1000;
        dic[@"withdrawTime"] = @(withdrawTime);
    }
//    if(_recordTime && [_recordTime isKindOfClass:[NSDate class]])
//    {
//        long long recordTime = _recordTime.timeIntervalSince1970*1000;
//        dic[@"recordTime"] = @(recordTime);
//    }
    return YES;
}


@end
