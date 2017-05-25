//
//  SQLoggerMgr.h
//  kaisafax
//
//  Created by semny on 16/6/27.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SQLoggerMgr : NSObject

/**
 *  日志工具单例方法
 *
 *  @return 单例对象
 */
+(id)sharedInstance;

#pragma mark - 日志信息
- (void)loggerInfo:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

- (void)loggerDebug:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

- (void)loggerWarn:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

- (void)loggerError:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
@end
