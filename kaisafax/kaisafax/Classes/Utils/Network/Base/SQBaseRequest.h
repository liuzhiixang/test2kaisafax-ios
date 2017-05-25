//
//  SQBaseRequest.h
//  kaisafax
//
//  Created by semny on 8/6/15.
//  Copyright (c) 2015 kaisafax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
//#import "AFDownloadRequestOperation.h"
//#import "SQResponseItem.h"
#import "SQRequestItem.h"
#import "SQRequestConst.h"


typedef NS_ENUM(NSInteger , SQRequestPriority) {
    SQRequestPriorityLow = -4L,
    SQRequestPriorityDefault = 0,
    SQRequestPriorityHigh = 4,
};

typedef void (^AFConstructingBlock)(id<AFMultipartFormData> formData);
typedef void (^SQDownloadProgressBlock)(NSURLSessionDownloadTask *task, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile);

@class SQBaseRequest;

///* 当request成功后的 responseBlock */
//typedef void (^SQRequestSucessBlock)(__kindof SQBaseRequest *request, SQResponseItem *response);
///* 请求失败的时候 */
//typedef void (^SQRequestFailureBlock)(__kindof SQBaseRequest *request, NSError *error);
/* 当request成功后的 responseBlock */
typedef void (^SQRequestSucessBlock)(SQBaseRequest *request);
/* 请求失败的时候 */
typedef void (^SQRequestFailureBlock)(SQBaseRequest *request);

/* 进度更新的时候 */
typedef void (^SQProgressBlock)(SQBaseRequest *request, NSInteger bytes, long long totalBytes, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile);

//序列化
typedef NSString * (^SQRequestSerializerBlock)(NSURLRequest *request, id parameters, NSError *__autoreleasing *error);

@protocol SQRequestDelegate <NSObject>

@optional
//- (void)requestFinished:(SQBaseRequest *)request result:(SQResponseItem *)result;
//- (void)requestFailed:(SQBaseRequest *)request error:(NSError *)error;
- (void)requestFinished:(SQBaseRequest *)request;
- (void)requestFailed:(SQBaseRequest *)request;

//进度代理
- (void)updateProgress:(SQBaseRequest *)request bytes:(long long)bytes totalBytes:(long long)totalBytes totalBytesExpected:(long long)totalBytesExpected totalBytesReadForFile:(long long)totalBytesReadForFile totalBytesExpectedToReadForFile:(long long)totalBytesExpectedToReadForFile;

//- (void)clearRequest;

@end

@protocol SQRequestAccessory <NSObject>

@optional

- (void)requestWillStart:(id)request;
- (void)requestWillStop:(id)request;
- (void)requestDidStop:(id)request;

@end

@interface SQBaseRequest : NSObject

/// Tag
//@property (nonatomic, assign) NSInteger tag;

/// User info
@property (nonatomic, strong) NSDictionary *userInfo;

//AFN3.0以后使用的事物
@property (nonatomic, strong) NSURLSessionTask *requestOperation;

/// request delegate object
@property (nonatomic, weak) id<SQRequestDelegate> delegate;

@property (nonatomic, strong, readonly) NSDictionary *responseHeaders;

@property (nonatomic, copy) SQRequestSucessBlock successCompletionBlock;

@property (nonatomic, copy) SQRequestFailureBlock failureCompletionBlock;

//当需要断点续传时，获得下载进度的回调
@property (nonatomic, copy) SQDownloadProgressBlock downloadProgressBlock;

//当POST的内容表单格式提交的时候数据组合回调
@property (nonatomic, copy) AFConstructingBlock constructingBlock;

@property (nonatomic, strong) NSMutableArray *requestAccessories;

/// 请求的优先级, 优先级高的请求会从请求队列中优先出列
@property (nonatomic, assign) SQRequestPriority requestPriority;

/// Return cancelled state of request operation
@property (nonatomic, readonly, getter=isCancelled) BOOL cancelled;
@property (nonatomic, readonly, getter=isExecuting) BOOL executing;
@property (nonatomic, readonly, getter=isFinished) BOOL finished;
@property (nonatomic, readonly, getter=isSuspended) BOOL suspended;
//已经发送了，请求包标志，和request状态无关
@property (nonatomic, assign, getter=isSended) BOOL sended;

//请求协议体
@property (nonatomic, strong) SQRequestItem *requestProtocol;

//序列化格式类型
@property (nonatomic, assign) SQRequestSerializerType requestSerializerType;
//序列化block
@property (nonatomic, copy) SQRequestSerializerBlock requestSerializerBlock;

//超时设置
@property (nonatomic, assign) NSTimeInterval requestTimeoutInterval;

//请求的Server用户名
@property (nonatomic, copy) NSString *requestServerUserName;
//请求的Server密码
@property (nonatomic, copy) NSString *requestServerPassword;

//在HTTP报头添加的自定义参数
@property (nonatomic, strong) NSDictionary *requestHeaderFieldValueDictionary;

//当需要断点续传时，指定续传的地址
@property (nonatomic, copy) NSString *resumableDownloadPath;

#pragma mark - 结果数据
//从服务器返回的数据(二进制数据)
@property (nonatomic, strong) NSData *responseData;

//从服务器返回的数据(已经解析好的)
@property (nonatomic, strong) id responseObject;

//是否是从缓存文件中读取出来的
@property (nonatomic, assign) BOOL readFromCache;

//整个请求到响应的总时长
@property (nonatomic, assign) NSTimeInterval time;

#pragma mark - 结果状态
@property (nonatomic, readonly) NSInteger responseStatusCode;

@property (nonatomic, strong) NSError *requestOperationError;

#pragma mark - 操作方法
/// append self to request queue
- (void)start;

/// remove self from request queue
- (void)stop;

#pragma mark - Request status
- (BOOL)isCancelled;

- (BOOL)isExecuting;

- (BOOL)isFinished;

- (BOOL)isSuspended;

/// block回调
- (void)startWithCompletionBlockWithSuccess:(SQRequestSucessBlock)success
                                    failure:(SQRequestFailureBlock)failure;

- (void)setCompletionBlockWithSuccess:(SQRequestSucessBlock)success
                              failure:(SQRequestFailureBlock)failure;

/// 把block置nil来打破循环引用
- (void)clearCompletionBlock;

/// Request Accessory，可以hook Request的start和stop
- (void)addAccessory:(id<SQRequestAccessory>)accessory;

/// 以下方法由子类继承来覆盖默认值

// 请求成功的回调
- (void)requestCompleteFilter;

// 请求失败的回调
- (void)requestFailedFilter;

/// 用于在cache结果，计算cache文件名时，忽略掉一些指定的参数
- (id)cacheFileNameFilterForRequestArgument:(id)argument;

/// 请求的Server用户名和密码
- (NSArray *)requestAuthorizationHeaderFieldArray;

/// 构建自定义的UrlRequest，
/// 若这个方法返回非nil对象，会忽略requestUrl, requestArgument, requestMethod, requestSerializerType
- (NSURLRequest *)buildCustomUrlRequest;

// 用于检查Status Code是否正常的方法
- (BOOL)statusCodeValidator;

// 当需要断点续传时，指定续传的地址
- (NSString *)resumableDownloadPath;

// 当需要断点续传时，获得下载进度的回调
//- (SQDownloadProgressBlock)resumableDownloadProgressBlock;

@end
