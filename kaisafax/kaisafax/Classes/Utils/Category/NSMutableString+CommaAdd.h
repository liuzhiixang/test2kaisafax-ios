//
//  NSMutableString+CommaAdd.h
//  sxfax
//
//  Created by philipyu on 16/5/9.
//  Copyright © 2016年 com.sxfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableString (CommaAdd)
/**
 *   将字符串转化成金融用的格式字符串(比如10000转成10，000)
 *
 *  @param str 被转化的字符串
 *  @param isDot 是否加小数点 yes：保留小数点后两位 no：取整数，不管小数点后数据
 *
 *  @return 格式化后的货币字符串值，精确到毛
 */
+(NSMutableString*)CommaAddWithStr:(NSString *)str dotStatus:(BOOL)isDot;
@end
