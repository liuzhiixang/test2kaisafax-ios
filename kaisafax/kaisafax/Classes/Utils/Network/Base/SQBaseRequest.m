//
//  SQBaseRequest.m
//  kaisafax
//
//  Created by semny on 8/6/15.
//  Copyright (c) 2015 kaisafax. All rights reserved.
//

#import "SQBaseRequest.h"
#import "SQNetworkAgent.h"
#import "SQNetworkPrivate.h"

@interface SQBaseRequest()

@end

//默认超时60秒
#define KRequestTimeoutIntervalDefault    60

@implementation SQBaseRequest

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        //默认的请求实体数据
        self.requestProtocol = [[SQRequestItem alloc] init];
        self.requestProtocol.method = SQRequestMethodGet;
        //默认不使用CDN
        self.requestProtocol.isUseCND = NO;
        
        //默认超时时间
        self.requestTimeoutInterval = KRequestTimeoutIntervalDefault;
        
        //默认序列化类型
        self.requestSerializerType = SQRequestSerializerTypeHTTP;
    }
    return self;
}

- (void)setDelegate:(id<SQRequestDelegate>)delegate
{
    DEBUGG(@"%s, delegate11:%@", __FUNCTION__, delegate);
    _delegate = delegate;
    DEBUGG(@"%s, delegate22:%@", __FUNCTION__, _delegate);
}

// for subclasses to overwrite
- (void)requestCompleteFilter {
}

- (void)requestFailedFilter {
}

- (id)cacheFileNameFilterForRequestArgument:(id)argument {
    return argument;
}

- (NSArray *)requestAuthorizationHeaderFieldArray {
    return nil;
}

- (NSURLRequest *)buildCustomUrlRequest {
    return nil;
}

- (BOOL)statusCodeValidator {
    NSInteger statusCode = [self responseStatusCode];
    if (statusCode >= 200 && statusCode <=299) {
        return YES;
    } else {
        return NO;
    }
}

//- (AFConstructingBlock)constructingBodyBlock {
//    return nil;
//}

- (NSString *)resumableDownloadPath {
    return nil;
}

//- (SQDownloadProgressBlock)resumableDownloadProgressBlock
//{
//    return nil;
//}

/// append self to request queue
- (void)start {
    [self toggleAccessoriesWillStartCallBack];
    [[SQNetworkAgent sharedInstance] addRequest:self];
}

/// remove self from request queue
- (void)stop {
    [self toggleAccessoriesWillStopCallBack];
    self.delegate = nil;
    [[SQNetworkAgent sharedInstance] cancelRequest:self];
    [self toggleAccessoriesDidStopCallBack];
}

- (void)startWithCompletionBlockWithSuccess:(SQRequestSucessBlock)success
                                    failure:(SQRequestFailureBlock)failure {
    [self setCompletionBlockWithSuccess:success failure:failure];
    [self start];
}

- (void)setCompletionBlockWithSuccess:(SQRequestSucessBlock)success
                              failure:(SQRequestFailureBlock)failure {
    self.successCompletionBlock = success;
    self.failureCompletionBlock = failure;
}

- (void)clearCompletionBlock {
    // nil out to break the retain cycle.
    self.successCompletionBlock = nil;
    self.failureCompletionBlock = nil;
}

- (NSInteger)responseStatusCode
{
    NSInteger statusCode = -1;
    NSURLResponse *response = self.requestOperation.response;
    if (response && [response isKindOfClass:[NSHTTPURLResponse class]])
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        statusCode = httpResponse.statusCode;
        return statusCode;
    }
    return statusCode;
}

- (NSDictionary *)responseHeaders
{
    NSURLResponse *response = self.requestOperation.response;
    if (response && [response isKindOfClass:[NSHTTPURLResponse class]])
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        return httpResponse.allHeaderFields;
    }
    return nil;
}

#pragma mark - Request status
- (BOOL)isCancelled
{
    return self.requestOperation.state==NSURLSessionTaskStateCanceling;
}

- (BOOL)isExecuting
{
    return self.requestOperation.state==NSURLSessionTaskStateRunning;
}

- (BOOL)isFinished
{
    return self.requestOperation.state==NSURLSessionTaskStateCompleted;
}

- (BOOL)isSuspended
{
    return self.requestOperation.state==NSURLSessionTaskStateSuspended;
}

#pragma mark - Request Accessories

- (void)addAccessory:(id<SQRequestAccessory>)accessory {
    if (!self.requestAccessories) {
        self.requestAccessories = [NSMutableArray array];
    }
    [self.requestAccessories addObject:accessory];
}

@end
