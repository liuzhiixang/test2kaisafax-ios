//
//  NSUserDefaults+Coder.m
//  SQTest
//
//  Created by Semny on 14/11/28.
//  Copyright (c) 2014年 JW. All rights reserved.
//

#import "NSUserDefaults+Coder.h"

@implementation NSUserDefaults (Coder)

- (id)decodeObjectForKey:(NSString *)key
{
    id value = nil;
    if (key)
    {
        NSData *data = [self objectForKey:key];
        if (data && data.length > 0)
        {
            //解决异常数据解码crash
            @try {
                value = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            }
            @catch (NSException *exception) {
                return value;
            }
            @finally {
            }
        }
        return value;
    }
    return value;
}

- (void)setEncodeObject:(id)value forKey:(NSString *)key
{
    if (value && key)
    {
        NSData * data = [NSKeyedArchiver archivedDataWithRootObject:value];
        [self setObject:data forKey:key];
    }
}

@end
