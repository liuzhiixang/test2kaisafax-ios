//
//  KSPersonInfoEntity.m
//  kaisafax
//
//  Created by BeiYu on 2016/11/15.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSPersonInfoEntity.h"
#import "KSAddrEntity.h"
#import "KSContactEntity.h"


@implementation KSPersonInfoEntity
+ (NSDictionary *)modelContainerPropertyGenericClass
{
    // value should be Class or Class name.
    return @{@"addrData" : KSAddrEntity.class,
             @"contactData" : KSContactEntity.class};
}

+ (NSDictionary *)modelCustomPropertyMapper
{
    return @{@"addrData" : @"receiverAddress",
             @"contactData" : @"contact"};
}

// 当 JSON 转为 Model 完成后，该方法会被调用。
// 你可以在这里对数据进行校验，如果校验不通过，可以返回 NO，则该 Model 会被忽略。
// 你也可以在这里做一些自动转换不能完成的工作。
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic
{
    NSNumber *registerTime = dic[@"registerTime"];

    
    //校验数据是不是存在(需要判断数据是否异常才需要处理)
    //if (![allocatedTime isKindOfClass:[NSNumber class]] || ![invokedTime isKindOfClass:[NSNumber class]] || ![consumedTime isKindOfClass:[NSNumber class]] || ![expiredTime isKindOfClass:[NSNumber class]] || ![withdrawTime isKindOfClass:[NSNumber class]]![recordTime isKindOfClass:[NSNumber class]]) return NO;
    if(registerTime && [registerTime isKindOfClass:[NSNumber class]])
    {
        _registerTime = [KSBaseEntity dateWithIntervalTime:registerTime.longLongValue];
    }

    return YES;
}
@end
