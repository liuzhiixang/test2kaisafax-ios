//
//  SQBatchRequest.m
//  kaisafax
//
//  Created by semny on 16/7/14.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "SQBatchRequest.h"
#import "SQNetworkPrivate.h"
#import "SQBatchRequestAgent.h"

@interface SQBatchRequest() <SQRequestDelegate>

@property (nonatomic, assign) NSInteger finishedCount;
@property (nonatomic, assign, getter=isSuccess) BOOL success;

@end

@implementation SQBatchRequest

- (id)initWithRequestArray:(NSArray *)requestArray {
    self = [super init];
    if (self) {
        _requestArray = [requestArray copy];
        _finishedCount = 0;
        //默认成功
        _success = YES;
        for (SQBaseRequest * req in _requestArray) {
            if (![req isKindOfClass:[SQBaseRequest class]]) {
                SQNLog(@"Error, request item must be SQBaseRequest instance.");
                return nil;
            }
        }
    }
    return self;
}

- (BOOL)isSuccess
{
    return _success;
}

#pragma mark - 操作方法
- (void)start {
    if (_finishedCount > 0) {
        SQNLog(@"Error! Batch request has already started.");
        return;
    }
    [[SQBatchRequestAgent sharedInstance] addBatchRequest:self];
    [self toggleAccessoriesWillStartCallBack];
    for (SQBaseRequest * req in _requestArray)
    {
        SQNLog(@"request: %@",req);
        req.delegate = self;
        [req start];
    }
}

- (void)stop {
    [self toggleAccessoriesWillStopCallBack];
    _delegate = nil;
    [self clearRequest];
    [self toggleAccessoriesDidStopCallBack];
    [[SQBatchRequestAgent sharedInstance] removeBatchRequest:self];
}

- (void)startWithCompletionBlockWithSuccess:(SQBatchRequestSucessBlock)success
                                    failure:(SQBatchRequestFailureBlock)failure
                                 executingS:(SQBatchRequestExecutingSuccessBlock)executingS
                                 executingF:(SQBatchRequestExecutingFailureBlock)executingF
{
    [self setCompletionBlockWithSuccess:success failure:failure executingS:executingS executingF:executingF];
    [self start];
}

- (void)setCompletionBlockWithSuccess:(SQBatchRequestSucessBlock)success
                              failure:(SQBatchRequestFailureBlock)failure
                           executingS:(SQBatchRequestExecutingSuccessBlock)executingS
                           executingF:(SQBatchRequestExecutingFailureBlock)executingF
{
    self.successCompletionBlock = success;
    self.failureCompletionBlock = failure;
    self.executingSBlock = executingS;
    self.executingFBlock = executingF;
}

- (void)clearCompletionBlock {
    // nil out to break the retain cycle.
    self.successCompletionBlock = nil;
    self.failureCompletionBlock = nil;
    self.executingSBlock = nil;
    self.executingFBlock = nil;
}

//- (BOOL)isDataFromCache {
//    BOOL result = YES;
//    for (SQBaseRequest *request in _requestArray) {
//        if (!request.isDataFromCache) {
//            result = NO;
//        }
//    }
//    return result;
//}

- (void)dealloc {
    [self clearRequest];
}

#pragma mark - Network Request Delegate

- (void)requestFinished:(SQBaseRequest *)request
{
    //成功
    [self handleRequestResultWith:request isSuccess:YES];
}

- (void)requestFailed:(SQBaseRequest *)request
{
    //失败
    [self handleRequestResultWith:request isSuccess:NO];
}

- (void)handleRequestResultWith:(SQBaseRequest *)request isSuccess:(BOOL)success
{
    //请求数量
    _finishedCount++;
    
    //判断是否请求错误
    if (success)
    {
        //处理请求是否全部成功的标志
        _success &= success;
        
        //执行过程回调
        if ([_delegate respondsToSelector:@selector(batchRequestExecuting:finishRequest:)]) {
            [_delegate batchRequestExecuting:self finishRequest:request];
        }
        if (_executingSBlock) {
            _executingSBlock(self, request);
        }
    }
    else
    {
        //失败的过程回调
        if ([_delegate respondsToSelector:@selector(batchRequestExecuting:failureRequest:)]) {
            [_delegate batchRequestExecuting:self failureRequest:request];
        }
        if (_executingFBlock) {
            _executingFBlock(self, request);
        }
    }
    
    //判断是否为最后的request，是的话则回调结束方法
    if (_finishedCount == _requestArray.count)
    {
        [self toggleAccessoriesWillStopCallBack];
        if (_success)
        {
            //成功的结束回调
            if ([_delegate respondsToSelector:@selector(batchRequestFinished:)]) {
                [_delegate batchRequestFinished:self];
            }
            if (_successCompletionBlock) {
                _successCompletionBlock(self);
            }
        }
        else
        {
            // 失败的结束回调
            if ([_delegate respondsToSelector:@selector(batchRequestFailed:)]) {
                [_delegate batchRequestFailed:self];
            }
            if (_failureCompletionBlock) {
                _failureCompletionBlock(self);
            }
        }
        
        [self clearCompletionBlock];
        [self toggleAccessoriesDidStopCallBack];
        //结束后清理掉batch请求
        [[SQBatchRequestAgent sharedInstance] removeBatchRequest:self];
    }
}

- (void)clearRequest {
    for (SQBaseRequest * req in _requestArray) {
        [req stop];
    }
    [self clearCompletionBlock];
}

#pragma mark - Request Accessoies

- (void)addAccessory:(id<SQRequestAccessory>)accessory {
    if (!self.requestAccessories) {
        self.requestAccessories = [NSMutableArray array];
    }
    [self.requestAccessories addObject:accessory];
}

@end
