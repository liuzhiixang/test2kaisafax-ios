//
//  NSURL+Util.m
//
//
//  Created by semny on 15/11/23.
//  Copyright © 2015年 semny. All rights reserved.
//

#import "NSURL+Util.h"
#import "NSString+Format.h"

@implementation NSURL (Util)

- (BOOL)hasHttpOrHttpsScheme
{
    BOOL result = NO;
    NSString *scheme = self.scheme;
    if ( ([scheme compare:@"http"  options:NSCaseInsensitiveSearch] == NSOrderedSame)
        || ([scheme compare:@"https" options:NSCaseInsensitiveSearch] == NSOrderedSame) )
    {
        result = YES;
    }
    return result;
}

- (BOOL)hasFileScheme
{
    BOOL result = NO;
    NSString *scheme = self.scheme;
    if ( ([scheme compare:@"file"  options:NSCaseInsensitiveSearch] == NSOrderedSame))
    {
        result = YES;
    }
    return result;
}

- (BOOL)hasAuthentication
{
    NSString *user = self.user;
    BOOL isEmptyOrWhitespace1 = [user isEmptyOrWhitespace];
    NSString *password = self.password;
    BOOL isEmptyOrWhitespace2 = [password isEmptyOrWhitespace];
    return isEmptyOrWhitespace1 || isEmptyOrWhitespace2;
}

- (BOOL)urlContainsString:(NSString *)string
{
    return [self.absoluteString rangeOfString:string].location != NSNotFound;
}
@end
