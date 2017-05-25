//
//  KSBussinessItemEntity.m
//  kaisafax
//
//  Created by semny on 16/8/1.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBussinessItemEntity.h"

@implementation KSBussinessItemEntity

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"ID" : @"id"};
}

// 当 JSON 转为 Model 完成后，该方法会被调用。
// 你可以在这里对数据进行校验，如果校验不通过，可以返回 NO，则该 Model 会被忽略。
// 你也可以在这里做一些自动转换不能完成的工作。
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
//    NSNumber *publishDate = dic[@"publishDate"];
//    NSNumber *systemTime = dic[@"systemTime"];
//    NSNumber *recordTime = dic[@"recordTime"];
//    
//    //if (![publishDate isKindOfClass:[NSNumber class]] || ![systemTime isKindOfClass:[NSNumber class]] || ![recordTime isKindOfClass:[NSNumber class]]) return NO;
//    if(publishDate && [publishDate isKindOfClass:[NSNumber class]])
//    {
//        _publishDate = [KSBaseEntity dateWithIntervalTime:publishDate.longLongValue];
//    }
//    if(systemTime && [systemTime isKindOfClass:[NSNumber class]])
//    {
//        _systemTime = [KSBaseEntity dateWithIntervalTime:systemTime.longLongValue];
//    }
//    if(recordTime && [recordTime isKindOfClass:[NSNumber class]])
//    {
//        _recordTime = [KSBaseEntity dateWithIntervalTime:recordTime.longLongValue];
//    }
//    
//    //增加的 以下参数提供给启动的服务广告使用
    NSNumber *startTime = dic[@"startTime"];
    NSNumber *endTime = dic[@"endTime"];
    NSNumber *updateTime = dic[@"updateTime"];

    if(startTime && [startTime isKindOfClass:[NSNumber class]])
    {
        _startTime = [KSBaseEntity dateWithIntervalTime:startTime.longLongValue];
    }
    if(endTime && [endTime isKindOfClass:[NSNumber class]])
    {
        _endTime = [KSBaseEntity dateWithIntervalTime:endTime.longLongValue];
    }
    if(updateTime && [updateTime isKindOfClass:[NSNumber class]])
    {
        _updateTime = [KSBaseEntity dateWithIntervalTime:updateTime.longLongValue];
    }
    return YES;
}

// 当 Model 转为 JSON 完成后，该方法会被调用。
// 你可以在这里对数据进行校验，如果校验不通过，可以返回 NO，则该 Model 会被忽略。
// 你也可以在这里做一些自动转换不能完成的工作。
- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic
{
    //if (!_publishDate || !_systemTime || !_recordTime) return NO;
    
//    if(_publishDate && [_publishDate isKindOfClass:[NSDate class]])
//    {
//        long long publishDate = _publishDate.timeIntervalSince1970*1000;
//        dic[@"publishDate"] = @(publishDate);
//    }
//    if(_systemTime && [_systemTime isKindOfClass:[NSDate class]])
//    {
//        long long systemTime = _systemTime.timeIntervalSince1970*1000;
//        dic[@"systemTime"] = @(systemTime);
//    }
//    if(_recordTime && [_recordTime isKindOfClass:[NSDate class]])
//    {
//        long long recordTime = _recordTime.timeIntervalSince1970*1000;
//        dic[@"recordTime"] = @(recordTime);
//    }
//    
//    //增加的 以下参数提供给启动的服务广告使用
    if(_startTime && [_startTime isKindOfClass:[NSDate class]])
    {
        long long startTime = _startTime.timeIntervalSince1970*1000;
        dic[@"startTime"] = @(startTime);
    }
    if(_endTime && [_endTime isKindOfClass:[NSDate class]])
    {
        long long endTime = _endTime.timeIntervalSince1970*1000;
        dic[@"endTime"] = @(endTime);
    }
    if(_updateTime && [_updateTime isKindOfClass:[NSDate class]])
    {
        long long updateTime = _updateTime.timeIntervalSince1970*1000;
        dic[@"updateTime"] = @(updateTime);
    }
    return YES;
}

@end
