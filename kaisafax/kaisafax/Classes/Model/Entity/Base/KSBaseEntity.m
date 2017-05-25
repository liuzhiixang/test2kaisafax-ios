//
//  KSBaseEntity
//
//  Created by Semny on 14-10-27.
//
//

#import "KSBaseEntity.h"
#import <objc/runtime.h>

//除法
NSDecimal CPTDecimalDivide(NSDecimal numerator, NSDecimal denominator)
{
    NSDecimal result;
    
    NSDecimalDivide(&result, &numerator, &denominator, NSRoundBankers);
    return result;
}

@implementation KSBaseEntity

+ (id)entity
{
    KSBaseEntity *entity = [[[self class] alloc] init];
    return entity;
}

+ (NSString *)formatRate:(CGFloat)rate{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setPositiveFormat:@"###,##0.00%;"];
    return [numberFormatter stringFromNumber:@(rate/100)];
}

+ (NSString *)formatAmount:(CGFloat)amount
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setPositiveFormat:@"###,##0.00;"];
    return [numberFormatter stringFromNumber:@(amount)];
}

+ (NSString *)formatAmountNotFloat:(NSUInteger)amount
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setPositiveFormat:@"###,###"];
    return [numberFormatter stringFromNumber:@(amount)];
}

+ (NSString *)formatAmount:(CGFloat)amount withUnit:(NSString *)unit
{
    return [NSString stringWithFormat:@"%@%@", [KSBaseEntity formatAmount:amount], unit];
}

+ (NSString *)formatDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)formatDigst:(NSString *)text left:(int)left right:(int)right
{
    if (text) {
        NSMutableString *tmpString = [NSMutableString string];
        [tmpString appendString:[text substringToIndex:left]];
        for (int i = 0; i < text.length - left - right; i++) {
            [tmpString appendString:@"*"];
        }
        [tmpString appendString:[text substringFromIndex:text.length - right]];
        return tmpString;
    }
    return @"*";
}

//格式化万元
+ (NSString *)formatTenThousandAmountString:(NSString *)amountStr
{
    NSString *tempStr = amountStr;
    if (!tempStr || tempStr.length <= 0)
    {
        tempStr = @"0.00";
        return tempStr;
    }
    
    //总金额
    NSDecimalNumber *totalExtractableAmtDec = [[NSDecimalNumber alloc] initWithString:amountStr];
    NSDecimal teaDec = totalExtractableAmtDec.decimalValue;
    //0
    NSDecimal ttDec1 = [NSDecimalNumber zero].decimalValue;
    NSComparisonResult result = NSDecimalCompare(&teaDec, &ttDec1);
    if (result == NSOrderedSame)
    {
        tempStr = @"0.00";
        return tempStr;
    }
    
    //万元
    NSDecimal ttDec = [NSDecimalNumber decimalNumberWithString:@"10000.00"].decimalValue;
    result = NSDecimalCompare(&teaDec, &ttDec);
    if (result == NSOrderedDescending)
    {
        //格式化万元
        //        _totalExtractableAmtFormat = teaDec.
        //除10000
        NSDecimal teaResult = CPTDecimalDivide(teaDec, ttDec);
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setPositiveFormat:@"###,##0.00;"];
        tempStr = [NSString stringWithFormat:@"%@%@",[numberFormatter stringForObjectValue:[NSDecimalNumber decimalNumberWithDecimal:teaResult]], KTTUnit];
    }
    else
    {
        //直接显示原始格式
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setPositiveFormat:@"###,##0.00;"];
        tempStr = [numberFormatter stringForObjectValue:[NSDecimalNumber decimalNumberWithString:amountStr]];;
    }
    if (!tempStr || tempStr.length <= 0)
    {
        tempStr = @"0.00";
        return tempStr;
    }
    return tempStr;
}

//格式化数字字符串
+ (NSString *)formatAmountString:(NSString *)amountStr
{
    NSString *tempStr = nil;
    if (!amountStr || amountStr.length <= 0)
    {
        tempStr = @"0.00";
        return tempStr;
    }
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setPositiveFormat:@"###,##0.00;"];
    tempStr = [numberFormatter stringForObjectValue:[NSDecimalNumber decimalNumberWithString:amountStr]];
    if (!tempStr || tempStr.length <= 0)
    {
        tempStr = @"0.00";
        return tempStr;
    }
    return tempStr;
}

//格式化数字字符串
+ (NSString *)formatAmountString:(NSString *)amountStr withUnit:(NSString *)unit
{
    return [NSString stringWithFormat:@"%@%@", [KSBaseEntity formatAmountString:amountStr], unit];
}

+ (NSString *)formatFloat:(CGFloat)value
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setPositiveFormat:@"##0.00;"];
    return [numberFormatter stringFromNumber:@(value)];
}

+ (BOOL)isValue1:(NSString *)v1 greaterValue2:(NSString *)v2
{
    NSDecimal discount1 = [[NSDecimalNumber decimalNumberWithString:v1] decimalValue];
    NSDecimal discount2 = [[NSDecimalNumber decimalNumberWithString:v2] decimalValue];
    NSComparisonResult result = NSDecimalCompare(&discount1, &discount2);
    return result == NSOrderedDescending;
}

+ (BOOL)isValue1:(NSString *)v1 lessValue2:(NSString *)v2
{
    NSDecimal discount1 = [[NSDecimalNumber decimalNumberWithString:v1] decimalValue];
    NSDecimal discount2 = [[NSDecimalNumber decimalNumberWithString:v2] decimalValue];
    NSComparisonResult result = NSDecimalCompare(&discount1, &discount2);
    return result == NSOrderedAscending;
}

+ (BOOL)isValue1:(NSString *)v1 sameValue2:(NSString *)v2
{
    NSDecimal discount1 = [[NSDecimalNumber decimalNumberWithString:v1] decimalValue];
    NSDecimal discount2 = [[NSDecimalNumber decimalNumberWithString:v2] decimalValue];
    NSComparisonResult result = NSDecimalCompare(&discount1, &discount2);
    return result == NSOrderedSame;
}

/**
 *  @author semny
 *
 *  1970毫秒数据转化为NSDate
 *
 *  @param msec 毫秒
 *
 *  @return NSDate对象
 */
+ (NSDate *)dateWithIntervalTime:(long long)msec
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:msec/1000];
    return date;
}

+ (BOOL)isObject1:(id)o1 isSameObject2:(id)o2
{
    NSString *json1 = [o1 yy_modelToJSONString];
    NSString *json2 = [o2 yy_modelToJSONString];
    return [json1 isEqualToString:json2];
}

#pragma mark - 编解码，描述，copy方法(使用YYModel作为解析数据model相关的工具)
/**
- (void)encodeWithCoder:(NSCoder *)coder
{
    [self encodeProperties:coder];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init])
    {
        [self decodeProperties:decoder];
    }
    return self;
}

- (void)decodeProperties:(NSCoder *)decoder
{
    unsigned int outCount = 0;
    unsigned int i = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i < outCount; i++)
    {
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
        id propertyValue = [decoder decodeObjectForKey:propertyName];
        if (propertyValue) {
            [self setValue:propertyValue forKey:propertyName];
        }
    }
    free(properties);
}

- (void)encodeProperties:(NSCoder *)coder
{
    unsigned int outCount = 0;
    unsigned int i = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i < outCount; i++)
    {
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
        id propertyValue = [self valueForKey:propertyName];
        
        [coder encodeObject:propertyValue forKey:propertyName];
    }
    free(properties);
}

- (NSString *)description
{
    unsigned int outCount = 0;
    unsigned int i = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    NSMutableString *str = [[NSMutableString alloc] init];
    for (i = 0; i < outCount; i++)
    {
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
        [str appendString:propertyName];
        [str appendString:@":"];
        id propertyValue = [self valueForKey:propertyName];
        if (propertyValue==nil) {
            [str appendString:@"nil"];
        }else{
            [str appendString:[propertyValue description]];
        }
        [str appendString:@","];
    }
    free(properties);
    return str;
}

- (id)copy
{
    Class instanceClass = [self class];
    id instance = [[instanceClass alloc]init];
    unsigned int propertyCount = 0;
    
    objc_property_t * properties = class_copyPropertyList(instanceClass, &propertyCount);
    for (int i = 0 ; i < propertyCount; i ++) {
        objc_property_t property = properties[i];
        NSString * propertyName = [NSString stringWithUTF8String:property_getName(property)];
        
        id propertyValue = [self valueForKey:propertyName];
        
        id newProperty = [propertyValue copy];
        
        [instance setValue:newProperty forKey:propertyName];
    }
    free(properties);
    return instance;
}
*/

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    //使用YYModel的encode方法
    [self yy_modelEncodeWithCoder:aCoder];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    //使用YYModel的decode并且初始化方法
    self = [super init];
    return [self yy_modelInitWithCoder:aDecoder];
}

- (NSString *)description
{
    //使用YYModel的description描述方法
    return [self yy_modelDescription];
}

- (id)copy
{
    //使用YYModel的copy方法
    return [self yy_modelCopy];
}

- (id)copyWithZone:(NSZone *)zone
{
    //使用YYModel的yy_modelCopy方法
    return [self yy_modelCopy];
}

- (NSUInteger)hash
{
    //使用YYModel的hash方法
    return [self yy_modelHash];
}

- (BOOL)isEqual:(id)object
{
    //使用YYModel的isEqual方法
    return [self yy_modelIsEqual:object];
}

@end
