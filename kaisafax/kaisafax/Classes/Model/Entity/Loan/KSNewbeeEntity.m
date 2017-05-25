//
//  KSNewbeeEntity.m
//  kaisafax
//
//  Created by semny on 16/8/1.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSNewbeeEntity.h"

@implementation KSNewbeeEntity

+ (NSDictionary *)modelContainerPropertyGenericClass
{
	// value should be Class or Class name.
	return @{ @"loan" : [KSLoanItemEntity class] };
}

//+ (NSDictionary *)modelCustomPropertyMapper {
//    return @{@"loanData": @"sticky"};
//}

// 当 JSON 转为 Model 完成后，该方法会被调用。
// 你可以在这里对数据进行校验，如果校验不通过，可以返回 NO，则该 Model 会被忽略。
// 你也可以在这里做一些自动转换不能完成的工作。
//- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
////    NSNumber *serverTime = dic[@"serverTime"];
//
//    //    if (![serverTime isKindOfClass:[NSNumber class]]) return NO;
////    if(serverTime && [serverTime isKindOfClass:[NSNumber class]])
////    {
////        _serverTime = [KSBaseEntity dateWithIntervalTime:serverTime.longLongValue];
////    }
//    return YES;
//}

// 当 Model 转为 JSON 完成后，该方法会被调用。
// 你可以在这里对数据进行校验，如果校验不通过，可以返回 NO，则该 Model 会被忽略。
// 你也可以在这里做一些自动转换不能完成的工作。
//- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic
//{
//    //if (!_serverTime) return NO;
////    if(_serverTime && [_serverTime isKindOfClass:[NSDate class]])
////    {
////        long long serverTime = _serverTime.timeIntervalSince1970*1000;
////        dic[@"serverTime"] = @(serverTime);
////    }
//    return YES;
//}
- (BOOL)isCanInvest
{
	return _testLoan;
}

- (NSString *)getNewbeeStatusText
{
	NSString *status = nil;
	if (![self isCanInvest])
		status = @"已购买";
	return status;
}

- (NSUInteger)getCanInvestMaxInAvailable:(NSUInteger)available
{
	NSUInteger sum = 0;
	if (available >= _loan.investRule.minAmount)
	{
		sum = MIN(available, _newbeeAmount);
		sum -= (sum % _loan.investRule.stepAmount);
	}
	return sum;
}

@end
