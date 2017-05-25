//
//  KSJDExtractInfoEntity.m
//  kaisafax
//
//  Created by semny on 17/3/23.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSJDExtractItemEntity.h"

@implementation KSJDExtractItemEntity

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"ID" : @"id"};
}

// 当 JSON 转为 Model 完成后，该方法会被调用。
// 你可以在这里对数据进行校验，如果校验不通过，可以返回 NO，则该 Model 会被忽略。
// 你也可以在这里做一些自动转换不能完成的工作。
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    NSNumber *createTime = dic[@"createTime"];
    
    //    if (![investTime isKindOfClass:[NSNumber class]]) return NO;
    if(createTime && [createTime isKindOfClass:[NSNumber class]])
    {
        _createTime = [KSBaseEntity dateWithIntervalTime:createTime.longLongValue];
    }
    return YES;
}


// 当 Model 转为 JSON 完成后，该方法会被调用。
// 你可以在这里对数据进行校验，如果校验不通过，可以返回 NO，则该 Model 会被忽略。
// 你也可以在这里做一些自动转换不能完成的工作。
- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic
{
    //if (!_investTime) return NO;
    if(_createTime && [_createTime isKindOfClass:[NSDate class]])
    {
        long long time = _createTime.timeIntervalSince1970*1000;
        dic[@"createTime"] = @(time);
    }
    return YES;
}

@end
