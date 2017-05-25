//
//  SQNetworkPrivate.h
//  kaisafax
//
//  Created by semny on 8/6/15.
//  Copyright (c) 2015 kaisafax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQBaseRequest.h"
#import "SQBatchRequest.h"
//#import "SQChainRequest.h"

FOUNDATION_EXPORT void SQNLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);

@interface SQNetworkPrivate : NSObject

+ (BOOL)checkJson:(id)json withValidator:(id)validatorJson;

+ (NSString *)urlStringWithOriginUrlString:(NSString *)originUrlString
                          appendParameters:(NSDictionary *)parameters;

+ (void)addDoNotBackupAttribute:(NSString *)path;

+ (NSString *)md5StringFromString:(NSString *)string;

+ (NSString *)appVersionString;

@end

@interface SQBaseRequest (RequestAccessory)

- (void)toggleAccessoriesWillStartCallBack;
- (void)toggleAccessoriesWillStopCallBack;
- (void)toggleAccessoriesDidStopCallBack;

@end

@interface SQBatchRequest (RequestAccessory)

- (void)toggleAccessoriesWillStartCallBack;
- (void)toggleAccessoriesWillStopCallBack;
- (void)toggleAccessoriesDidStopCallBack;

@end
//
//@interface SQChainRequest (RequestAccessory)
//
//- (void)toggleAccessoriesWillStartCallBack;
//- (void)toggleAccessoriesWillStopCallBack;
//- (void)toggleAccessoriesDidStopCallBack;
//
//@end


