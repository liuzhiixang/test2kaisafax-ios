//
//  NSMutableString+CommaAdd.m
//  sxfax
//
//  Created by philipyu on 16/5/9.
//  Copyright © 2016年 com.sxfax. All rights reserved.
//

#import "NSMutableString+CommaAdd.h"

@implementation NSMutableString (CommaAdd)
+(NSMutableString*)CommaAddWithStr:(NSString *)str dotStatus:(BOOL)isDot
{
    NSString *dotStr= @"";
    
    if (!str)
    {
        return nil;
    }
    
    // 要求保留两位小数
    if (isDot)
    {
//       NSString *douStr = [NSString stringWithFormat:@"%.2f", totalvalue];
        if (str.length > 3)
        {
            //  取出小数点后面的部分
            dotStr = [str substringFromIndex:(str.length - 3)];
        }
        else
        {
            //  加上小数点不够3位，直接返回字符串
            return (NSMutableString*)str;
        }
       
    }
    
    //    对整型部分每三位取出来存到数组
    long long value = [str longLongValue];

    NSMutableString *intergerStr = [NSMutableString stringWithFormat:@"%lld",value];
    NSMutableString *mutStr = [[NSMutableString alloc]init];
    NSMutableArray *arrays = [NSMutableArray array];
    NSUInteger length = intergerStr.length;
    
    while (length>3)
    {
        NSString *str = [intergerStr substringFromIndex:length-3];
        intergerStr = (NSMutableString*)[intergerStr substringToIndex:length-3];
        [arrays insertObject:str atIndex:0];
        length -= 3;
    }
    
    [mutStr appendString:intergerStr];
    
    // 从数组中取出字符串，拼接起来
    if (arrays.count>0)
    {
        
        for (NSString *str in arrays)
        {
            [mutStr appendString:@","];
            [mutStr appendString:str];
        }
    }
    
    // 保留小数的，拼接在最后
    if (isDot)
    {
        [mutStr appendString:dotStr];
    }
    
    return mutStr;
}
@end
