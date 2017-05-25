//
//  SQNetworkAgent.h
//  kaisafax
//
//  Created by semny on 8/6/15.
//  Copyright (c) 2015 kaisafax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQRequestManagerDelegate.h"
#import "AFNetworking.h"
#import "SQNetworkConfig.h"
#import "SQNetworkPrivate.h"
#import "SQBaseRequest.h"

//请求错误描述的key
#define KRequestErrorDomainKey @"RequestErrorDomainKey"
//下载地址的key
#define KDownloadPathKey @"downloadPath"

@interface SQNetworkAgent : NSObject<SQRequestManagerDelegate>

+ (SQNetworkAgent *)sharedInstance;

- (void)addRequest:(SQBaseRequest *)request;
//请求
- (void)requestServiceWith:(SQBaseRequest*)request;

- (void)cancelRequest:(SQBaseRequest *)request;

- (void)cancelAllRequests;

//清理并且回调所有剩余的request
- (void)invokeAllDelegateWithErrorCode:(NSInteger)errorCode;

//获取缓存的request
//- (SQBaseRequest*)getRequestForOperation:(NSURLSessionTask*)operation;
- (void)addRequestInRecord:(SQBaseRequest *)request;
- (void)removeRequestInRecord:(SQBaseRequest *)request;
- (NSInteger)countRequestInRecord;
- (SQBaseRequest*)requestInRecordAtIndex:(NSInteger)index;
@end
