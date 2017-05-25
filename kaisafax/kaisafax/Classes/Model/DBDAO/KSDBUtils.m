//
//  KSDBUtils.m
//  kaisafax
//
//  Created by Semny on 15/1/20.
//  Copyright (c) 2015年 kaisafax. All rights reserved.
//

#import "KSDBUtils.h"
#import "NSString+Format.h"
#import "NSString+Additions.h"
#import "NSDate+Utilities.h"

#pragma mark ----- 数据库数据类型校验 -----
/**
 *  检测指定插入数据库中的NSString对象是否为空，若为空，则使用@""代替
 *
 *  @param str 待转义NSString对象
 *
 *  @return 转义的返回值
 */
NSString *db_checkInputString  (NSString *str);

/**
 *  urlEncoding 处理
 *
 *  @param str 待转义NSString对象
 *
 *  @return 转义的返回值
 */
NSString *db_checkURLInputString(id str);

/**
 *  urlDecoding 处理
 *
 *  @param str 待转义NSString对象
 *
 *  @return 转义的返回值
 */
NSString *db_checkURLOutputString(id str);

/**
 *  转移从数据库取出的NSString对象是否为空，若为空，则使用@""代替
 *
 *  @param str 待转义NSString对象
 *
 *  @return 转义的返回值
 */
NSString *db_checkOutputString(id str);

/**
 *  获取指定日期对象距离1970年的秒数
 *
 *  @param date NSDate对象，假如日期对象为空，则使用当前日期
 *
 *  @return 返回日期对象距离1970年的秒数
 */
NSString* db_checkDate(id date);

NSString *db_checkInputString  (id str)
{
    str = str?str:@"";
    return str;
}

NSString *db_checkOutputString(id str)
{
    return str;
}

NSString *db_checkURLInputString(id str)
{
    str = str?[str URLEncodedString]:@"";
    return str;
}

NSString *db_checkURLOutputString(id str)
{
    str = str?[str URLDecodingString]:@"";
    return str;
}

NSString* db_checkDate(id date)
{
    if (!date) {
        date = (date?date:[NSDate date]);
    }
    if (![date isKindOfClass:[NSDate class]]) {
        ERROR(@"%@ 不是NSDate类型",date);
        return date;
    }
    
    return [date dateStringWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
}

#pragma mark -
#pragma mark -------------数据库操作工具类-----------------
@implementation KSDBUtils

/**
 *  初始化数据库
 */
+(void)startInitDB
{
    DEBUGG(@"KSDBUtils startInitDB()");
    [[KSDBHelper sharedInstance] startInitOrUpdate];
}

@end

