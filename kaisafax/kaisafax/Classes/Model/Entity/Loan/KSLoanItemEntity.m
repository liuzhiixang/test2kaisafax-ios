//
//  KSLoanItemEntity.m
//  kaisafax
//
//  Created by semny on 16/8/1.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSLoanItemEntity.h"
#import "KSRulesEntity.h"



#define STATUS_ARR   @[ @"抢标", \
                        @"已满标", \
                        @"放款中", \
                        @"还款中", \
                        @"已还清", \
                        @"已逾期"]

#define RECOMMED_ARR @[ @"无运营标签", \
                        @"尊享", \
                        @"热门",\
                        @"银行承兑", \
                        @"资信等级A", \
                        @"资信等级AA", \
                        @"资信等级AAA" \
]


#define TAGS_ARR @[@"",\
                   @"HONORABLE", \
                   @"RECOMMEND", \
                   @"BANKBILL",\
                   @"CREDITA", \
                   @"CREDITAA", \
                   @"CREDITAAA" \
                  ]

typedef NS_ENUM(NSInteger,KSLoanStatus)
{
    KSLoanStatusFundraising = 7,
    KSLoanStatusFinished = 9,
    KSLoanStatusInloan = 10,
    KSLoanStatusLoaned = 11,
    KSLoanStatusCleared = 12,
    KSLoanStatusOverdue = 13,
};

typedef NS_ENUM(NSInteger,KSLoanType)
{
    KSLoanTypeNewBee = 0,
    KSLoanTypeNormal = 999,
    KSLoanTypeJJS = 1000,
    KSLoanTypeTenementA = 3,
    KSLoanTypeTenementB = 4,
};



@implementation KSLoanItemEntity


+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"duration" : KSDurationEntity.class,
             @"freeDuration" : KSDurationEntity.class};
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"ID" : @"id",
             @"newbeeDescription" : @"description",
             @"investRule_minAmount" : @"investRule.minAmount",
             @"investRule_maxAmount" : @"investRule.maxAmount",
             @"investRule_stepAmount" : @"investRule.stepAmount",
             @"loanProduct" : @[@"loanProduct",@"product"],
             @"contractId" : @[@"contractId",@"contract"],
             @"sticky_flag" : @"sticky"
             };
}

// 当 JSON 转为 Model 完成后，该方法会被调用。
// 你可以在这里对数据进行校验，如果校验不通过，可以返回 NO，则该 Model 会被忽略。
// 你也可以在这里做一些自动转换不能完成的工作。

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic
{
//    NSNumber *submitTime = dic[@"submitTime"];
    NSNumber *finishTime = dic[@"finishTime"];
//    NSNumber *loanTime = dic[@"loanTime"];
    NSNumber *clearTime = dic[@"clearTime"];
//    NSNumber *valueDate = dic[@"valueDate"];
//    NSNumber *openTime = dic[@"openTime"];
    
    //校验数据是不是存在(需要判断数据是否异常才需要处理)
    //if (![submitTime isKindOfClass:[NSNumber class]] || ![finishTime isKindOfClass:[NSNumber class]] || ![loanTime isKindOfClass:[NSNumber class]] || ![clearTime isKindOfClass:[NSNumber class]] || ![valueDate isKindOfClass:[NSNumber class]]) return NO;
//    if(openTime && [openTime isKindOfClass:[NSNumber class]])
//    {
//        _openTimeDate = [KSBaseEntity dateWithIntervalTime:openTime.longLongValue];
//    }
//    if(submitTime && [submitTime isKindOfClass:[NSNumber class]])
//    {
//        _submitTime = [KSBaseEntity dateWithIntervalTime:submitTime.longLongValue];
//    }
    if(finishTime && [finishTime isKindOfClass:[NSNumber class]])
    {
        _finishTime = [KSBaseEntity dateWithIntervalTime:finishTime.longLongValue];
    }
//    if(loanTime && [loanTime isKindOfClass:[NSNumber class]])
//    {
//        _loanTime = [KSBaseEntity dateWithIntervalTime:loanTime.longLongValue];
//    }
    //为了解决接口返回的数据异常做了非0判断
    if(clearTime && [clearTime isKindOfClass:[NSNumber class]] && ![clearTime isEqual:@0])
    {
        _clearTime = [KSBaseEntity dateWithIntervalTime:clearTime.longLongValue];
    }
//    if(valueDate && [valueDate isKindOfClass:[NSNumber class]])
//    {
//        _valueDate = [KSBaseEntity dateWithIntervalTime:valueDate.longLongValue];
//    }
    return YES;
}

// 当 Model 转为 JSON 完成后，该方法会被调用。
// 你可以在这里对数据进行校验，如果校验不通过，可以返回 NO，则该 Model 会被忽略。
// 你也可以在这里做一些自动转换不能完成的工作。
- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic
{
    //校验数据是不是存在(需要判断数据是否异常才需要处理)
    //if (!_submitTime || !_finishTime || !_loanTime || !_clearTime || !_valueDate) return NO;
//    if(_openTimeDate && [_openTimeDate isKindOfClass:[NSDate class]])
//    {
//        long long openTime = _openTimeDate.timeIntervalSince1970*1000;
//        dic[@"openTime"] = @(openTime);
//    }
//    if(_submitTime && [_submitTime isKindOfClass:[NSDate class]])
//    {
//        long long submitTime = _submitTime.timeIntervalSince1970*1000;
//        dic[@"submitTime"] = @(submitTime);
//    }
    if(_finishTime && [_finishTime isKindOfClass:[NSDate class]])
    {
        long long finishTime = _finishTime.timeIntervalSince1970*1000;
        dic[@"finishTime"] = @(finishTime);
    }
//    if(_loanTime && [_loanTime isKindOfClass:[NSDate class]])
//    {
//        long long loanTime = _loanTime.timeIntervalSince1970*1000;
//        dic[@"loanTime"] = @(loanTime);
//    }
    if(_clearTime && [_clearTime isKindOfClass:[NSDate class]])
    {
        long long clearTime = _clearTime.timeIntervalSince1970*1000;
        dic[@"clearTime"] = @(clearTime);
    }
//    if(_valueDate && [_valueDate isKindOfClass:[NSDate class]])
//    {
//        long long valueDate = _valueDate.timeIntervalSince1970*1000;
//        dic[@"valueDate"] = @(valueDate);
//    }
    return YES;
}

//期限
- (NSString *)getDurationText
{
    KSUnitType unitype = _duration.unitType;
    if (unitype == KSUnitYear) {
        return [NSString stringWithFormat:@"%ld年", (long)_duration.value];
    }else if (unitype == KSUnitMonth){
        return [NSString stringWithFormat:@"%ld个月", (long)_duration.value];
    }
    return [NSString stringWithFormat:@"%ld天", (long)_duration.value];
}

//免费的期限
//- (NSString *)getFreeText
//{
//    KSUnitType unitype = _freeDuration.unitType;
//    if (unitype == KSUnitYear) {
//        return [NSString stringWithFormat:@"免%ld年物业费", (long)_freeDuration.value];
//    }else if (unitype == KSUnitMonth){
//        return [NSString stringWithFormat:@"免%ld个月物业费", (long)_freeDuration.value];
//    }
//    return [NSString stringWithFormat:@"免%ld天物业费", (long)_freeDuration.value];
//}

//年化率
- (NSString *)getRateText
{
    return [KSBaseEntity formatRate:_rate / 100];
}
//起投金额
- (NSString *)getInvestMinAmount
{
    return [KSBaseEntity formatAmount:_investRule.minAmount];
}

- (NSString *)getInvestMinAmountWithUnit:(NSString *)unit
{
    return [KSBaseEntity formatAmount:_investRule.minAmount withUnit:unit];
}

- (NSString *)getRepayMethodText{
    if(_repayMethod == 0)
        return REPAY_METHOD[_repayMethod];
    NSInteger method = (NSInteger)log2(_repayMethod);
    return REPAY_METHOD[method];
}

- (CGFloat)getProgress
{
    if (_amount <= 0) {
        return 0;
    }
    NSInteger t = (_amount-_leftAmount) * 10000 / _amount;
    if(t > 0 && t < 100)
    {
        t = 100;
    }
    else if(t > 9900 && t < 10000)
    {
        t= 9900;
    }
    CGFloat progress =  MIN(1, t / 10000.);
    return progress;
}

- (long)getCountdownTime
{
#warning todo schedule
//倒计时功能暂时关闭，
//    if (_status == KSLoanStatusLoaned) {
//        NSInteger now = [[NSDate new] timeIntervalSince1970];
//        return _openTime - now * 1000;
//    }
    return 0;
}

- (void)calcCountdownTime
{
    NSInteger now = [[NSDate new] timeIntervalSince1970];
    _openTime -= (_serverTime - now * 1000);
}


- (NSString *)getStatusText
{
//    if ((_loanProduct == KSLoanTypeNewBee) && ![self isLoanOpen]) {
//        return @"已购买";
//    }
    NSInteger index = 0;
    switch (_status) {
        case KSLoanStatusFundraising:
            index = 0;
            break;
        case KSLoanStatusFinished:
        case KSLoanStatusInloan:
            index = 1;
            break;
        case KSLoanStatusLoaned:
            index = 3;
            break;
        case KSLoanStatusCleared:
            index = 4;
            break;
        case KSLoanStatusOverdue:
            index = 5;
            break;
        default:
            break;
    }
    
    return STATUS_ARR[index];
}

- (BOOL)isLoanOpen{
    if (_loanProduct == KSLoanTypeNewBee) {
        
        return _amount > 0;
    }
    return (_status == KSLoanStatusFundraising);
}

- (NSString *)getRuleText
{
    return [NSString stringWithFormat:@"%ld元起投, %ld元递增", _investRule.minAmount, _investRule.stepAmount];
}

- (NSInteger)leftAmount
{
    //根据是否是新手标返回不同字段
//    if (_loanProduct == 0)
//    {
//        return _;
//    }
    return _leftAmount;
}

- (NSString *)getLeftAmountText{
    return [NSString stringWithFormat:@"剩余%@元", [KSBaseEntity formatAmountNotFloat:_leftAmount]];
}

- (NSString *)getRevenueFromAmount:(CGFloat)amount
{
    KSUnitType type = _duration.unitType;
    if (type == KSUnitDay ) {
        return [KSBaseEntity formatAmount:(amount * _rate * _duration.value / 365 / 10000)];
    }
    if (type == KSUnitMonth) {
        return [KSBaseEntity formatAmount:(amount * _rate * _duration.value / 12 / 10000)];
    }
    return [KSBaseEntity formatAmount:(amount * _rate * _duration.value / 10000)];
}

- (NSUInteger)getCanInvestMaxInAvailable:(NSUInteger)available
{
    NSUInteger sum = 0;
    if (available >= _investRule.minAmount)
    {
//        
//        if (_loanProduct == KSLoanTypeNewBee) {
//            sum = MIN(available, _amount);
//        }else{
//
//        }
        sum = MIN(available, _investRule.maxAmount);
        sum = MIN(sum, _leftAmount);
        sum -= (sum % _investRule.stepAmount);
    }
    return sum;
}

- (NSString *)getRecommendTag
{
    if (!(_recommendLabel==0)) {
        return RECOMMED_ARR[_recommendLabel];
    }
    return nil;
}

-(NSString*)getRecommendKey
{
    if (!(_recommendLabel==0)) {
        return TAGS_ARR[_recommendLabel];
    }
    return nil;
}

- (NSString *)getTextFormRecommendTag:(NSInteger)tag
{
    return RECOMMED_ARR[tag];
}

- (BOOL)isNewBee
{
    return (_loanProduct == KSLoanTypeNewBee);
}
@end
