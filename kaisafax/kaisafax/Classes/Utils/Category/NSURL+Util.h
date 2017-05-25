//
//  NSURL+Util.h
//
//
//  Created by semny on 15/11/23.
//  Copyright © 2015年 semny. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (Util)

/**
 *  是否包含网络协议头
 *
 *  @return YES：包含，NO，不包含
 */
- (BOOL)hasHttpOrHttpsScheme;

/**
 *  是否包含本地协议头
 *
 *  @return YES：包含，NO，不包含
 */
- (BOOL)hasFileScheme;

/**
 *  判断是否身份认证
 *
 *  @return YES：符合身份认证，NO：不符合
 */
- (BOOL)hasAuthentication;

@end
