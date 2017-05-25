//
//  KSBaseEntity
//
//  Created by Semny on 14-10-27.
//
//

#import <Foundation/Foundation.h>
#import <YYModel/YYModel.h>

/**
 *  @author semny
 *
 *  使用YYModel的数据Model对象解析，可以在子类中增加相应的解析模版，使得对象属性和json key相对应
 */
@interface KSBaseEntity : NSObject<NSCoding>

+ (id)entity;

+ (NSString *)formatRate:(CGFloat)rate;

+ (NSString *)formatAmount:(CGFloat)amount;

+ (NSString *)formatAmountNotFloat:(NSUInteger)amount;

+ (NSString *)formatAmount:(CGFloat)amount withUnit:(NSString *)unit;

+ (NSString *)formatDate:(NSDate *)date;

+ (NSString *)formatDigst:(NSString *)text left:(int)left right:(int)right;


/**
 判断两个对象里的值是否相等

 @param o1
 @param o2
 @return 
 */
+ (BOOL)isObject1:(id)o1 isSameObject2:(id)o2;



//v1  > v2 = YES
+ (BOOL)isValue1:(NSString *)v1 greaterValue2:(NSString *)v2;
//v1 < v2 = YES
+ (BOOL)isValue1:(NSString *)v1 lessValue2:(NSString *)v2;

+ (BOOL)isValue1:(NSString *)v1 sameValue2:(NSString *)v2;

//保留2位小数的浮点数
+ (NSString *)formatFloat:(CGFloat)value;

//格式化万元
+ (NSString *)formatTenThousandAmountString:(NSString *)amountStr;

//格式化数字字符串
+ (NSString *)formatAmountString:(NSString *)amountStr;
//格式化数字字符串
+ (NSString *)formatAmountString:(NSString *)amountStr withUnit:(NSString *)unit;

/**
 *  @author semny
 *
 *  1970毫秒数据转化为NSDate
 *
 *  @param msec 毫秒
 *
 *  @return NSDate对象
 */
+ (NSDate *)dateWithIntervalTime:(long long)msec;


@end
