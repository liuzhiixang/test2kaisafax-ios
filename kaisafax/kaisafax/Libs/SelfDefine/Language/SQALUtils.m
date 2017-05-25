//
//  SQALUtils.m
//
//
//  Created by Semny on 14/11/28.
//  Copyright (c) 2014年 semny. All rights reserved.
//

#import "SQALUtils.h"

@implementation SQALUtils

+ (NSString *)currentLanguage
{
    NSArray *preferedLanguages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [preferedLanguages firstObject];
    return currentLanguage;
}

+ (BOOL)isChineseLanguage
{
    NSRange range = [[SQALUtils currentLanguage] rangeOfString:@"zh-"];
    return range.length >0;
}

+ (NSString *)currentCountryCode
{
    NSString *code = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    return code;
}

+ (BOOL)isChinaLocaleCode
{
    NSRange range = [[SQALUtils currentCountryCode]rangeOfString:@"CN"];
    return range.length >0;
}

@end
