//
//  SQBatchRequest.h
//  kaisafax
//
//  Created by semny on 16/7/14.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQBaseRequest.h"

@class SQBatchRequest;

/* 当request成功后的 responseBlock */
typedef void (^SQBatchRequestSucessBlock)(SQBatchRequest *request);
/* 请求失败的时候 */
typedef void (^SQBatchRequestFailureBlock)(SQBatchRequest *request);

/* 当request成功后的 responseBlock */
typedef void (^SQBatchRequestExecutingSuccessBlock)(SQBatchRequest *request, SQBaseRequest *itemRequest);
typedef void (^SQBatchRequestExecutingFailureBlock)(SQBatchRequest *request, SQBaseRequest *itemRequest);


@protocol SQBatchRequestDelegate <NSObject>

@optional

//整个请求顺利完成的结果
- (void)batchRequestFinished:(SQBatchRequest *)batchRequest;
//整个请求失败的结果
- (void)batchRequestFailed:(SQBatchRequest *)batchRequest;
//Batch request过程中的所有请求过程(完成)
- (void)batchRequestExecuting:(SQBatchRequest *)batchRequest finishRequest:(SQBaseRequest *)itemRequest;
//Batch request过程中的所有请求过程(失败)
- (void)batchRequestExecuting:(SQBatchRequest *)batchRequest failureRequest:(SQBaseRequest *)itemRequest ;

@end

@interface SQBatchRequest : NSObject

@property (strong, nonatomic, readonly) NSArray *requestArray;

@property (weak, nonatomic) id<SQBatchRequestDelegate> delegate;

@property (nonatomic, copy) SQBatchRequestSucessBlock successCompletionBlock;

@property (nonatomic, copy) SQBatchRequestFailureBlock failureCompletionBlock;

@property (nonatomic, copy) SQBatchRequestExecutingSuccessBlock executingSBlock;

@property (nonatomic, copy) SQBatchRequestExecutingFailureBlock executingFBlock;

@property (nonatomic) NSInteger tag;

@property (nonatomic, strong) NSMutableArray *requestAccessories;

- (id)initWithRequestArray:(NSArray *)requestArray;

- (void)start;

- (void)stop;

/// block回调
- (void)startWithCompletionBlockWithSuccess:(SQBatchRequestSucessBlock)success
                                    failure:(SQBatchRequestFailureBlock)failure
                                  executingS:(SQBatchRequestExecutingSuccessBlock)executingS
                                  executingF:(SQBatchRequestExecutingFailureBlock)executingF;

- (void)setCompletionBlockWithSuccess:(SQBatchRequestSucessBlock)success
                              failure:(SQBatchRequestFailureBlock)failure
                           executingS:(SQBatchRequestExecutingSuccessBlock)executingS
                           executingF:(SQBatchRequestExecutingFailureBlock)executingF;

/// 把block置nil来打破循环引用
- (void)clearCompletionBlock;

/// Request Accessory，可以hook Request的start和stop
- (void)addAccessory:(id<SQRequestAccessory>)accessory;

/// 是否当前的数据从缓存获得
//- (BOOL)isDataFromCache;

@end
