//
//  KSCardItemEntity.m
//  kaisafax
//
//  Created by semny on 16/8/3.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSCardItemEntity.h"

@implementation KSCardItemEntity
+ (NSDictionary *)modelCustomPropertyMapper
{
    return @{@"cardId" : @"id"};
}

// 当 JSON 转为 Model 完成后，该方法会被调用。
// 你可以在这里对数据进行校验，如果校验不通过，可以返回 NO，则该 Model 会被忽略。
// 你也可以在这里做一些自动转换不能完成的工作。
//- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
//    NSNumber *recordTime = dic[@"recordTime"];
//    
//    //if (![recordTime isKindOfClass:[NSNumber class]]) return NO;
//    if(recordTime && [recordTime isKindOfClass:[NSNumber class]])
//    {
//        _recordTime = [KSBaseEntity dateWithIntervalTime:recordTime.longLongValue];
//    }
//    return YES;
//}
//
//// 当 Model 转为 JSON 完成后，该方法会被调用。
//// 你可以在这里对数据进行校验，如果校验不通过，可以返回 NO，则该 Model 会被忽略。
//// 你也可以在这里做一些自动转换不能完成的工作。
//- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic
//{
//    //if (!_recordTime) return NO;
//    
//    if(_recordTime && [_recordTime isKindOfClass:[NSDate class]])
//    {
//        long long recordTime = _recordTime.timeIntervalSince1970*1000;
//        dic[@"recordTime"] = @(recordTime);
//    }
//    return YES;
//}

- (NSString *)formatAccount
{
    if (_account.length > 0) {
        NSMutableString *sb = [NSMutableString string];
        NSInteger idx = 0;
        NSInteger step = 4;
        NSInteger maxLength = _account.length;
        while (idx < maxLength) {
            [sb appendString:[_account substringWithRange:NSMakeRange(idx, MIN(step, maxLength-idx))]];
            [sb appendString:@"  "];//加一个空格
            idx += step;
        }
        
        return sb;
    }
    return _account;
}

@end
