//
//  KSUserFRItemEntity.m
//  kaisafax
//
//  Created by semny on 16/8/3.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSUserFRItemEntity.h"

@implementation KSUserFRItemEntity

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"frId" : @"id",
             @"frDescription":@"description"
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"object" : KSRealmEntity.class};
}


// 当 JSON 转为 Model 完成后，该方法会被调用。
// 你可以在这里对数据进行校验，如果校验不通过，可以返回 NO，则该 Model 会被忽略。
// 你也可以在这里做一些自动转换不能完成的工作。
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    NSNumber *recordTime = dic[@"recordTime"];
    
    //if (![recordTime isKindOfClass:[NSNumber class]]) return NO;
    if(recordTime && [recordTime isKindOfClass:[NSNumber class]])
    {
        _recordTime = [KSBaseEntity dateWithIntervalTime:recordTime.longLongValue];
    }
    return YES;
}

// 当 Model 转为 JSON 完成后，该方法会被调用。
// 你可以在这里对数据进行校验，如果校验不通过，可以返回 NO，则该 Model 会被忽略。
// 你也可以在这里做一些自动转换不能完成的工作。
- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic
{
    //if (!_recordTime) return NO;
    
    if(_recordTime && [_recordTime isKindOfClass:[NSDate class]])
    {
        long long recordTime = _recordTime.timeIntervalSince1970*1000;
        dic[@"recordTime"] = @(recordTime);
    }
    return YES;
}

@end
