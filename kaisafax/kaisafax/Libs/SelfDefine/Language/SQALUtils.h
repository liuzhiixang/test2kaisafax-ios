//
//  SQALUtils.h
//
//
//  Created by semny on 14/11/28.
//  Copyright (c) 2014年 semny. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  区域语言相关的工具
 */
@interface SQALUtils : NSObject

+ (NSString *)currentLanguage;

+ (BOOL)isChineseLanguage;

+ (NSString *)currentCountryCode;

+ (BOOL)isChinaLocaleCode;
@end
