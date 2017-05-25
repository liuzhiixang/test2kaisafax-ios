//
//  NSUserDefaults+Coder.h
//  SQTest
//
//  Created by Semny on 14/11/28.
//  Copyright (c) 2014年 JW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (Coder)

- (id)decodeObjectForKey:(NSString *)defaultName;

- (void)setEncodeObject:(id)value forKey:(NSString *)defaultName;

@end
