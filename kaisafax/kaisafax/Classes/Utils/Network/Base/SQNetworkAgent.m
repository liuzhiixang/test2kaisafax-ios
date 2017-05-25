//
//  SQNetworkAgent.m
//  kaisafax
//
//  Created by semny on 8/6/15.
//  Copyright (c) 2015 kaisafax. All rights reserved.
//

#import "SQNetworkAgent.h"
#import "M13OrderedDictionary.h"

//static const CGFloat SQSessionTaskPriorityVeryLow = 0.0f;
static const CGFloat SQSessionTaskPriorityLow = 0.1f;
static const CGFloat SQSessionTaskPriorityNormal = 0.5f;
static const CGFloat SQSessionTaskPriorityHigh = 0.7f;
//static const CGFloat SQSessionTaskPriorityVeryHigh = 1.0f;
static const NSInteger SQSessionMaxConcurrentOperationCount = 4;

@implementation SQNetworkAgent {
    AFHTTPSessionManager *_manager;
    SQNetworkConfig *_config;
    //有序字典
    M13MutableOrderedDictionary *_requestsRecord;
    dispatch_queue_t _requestProcessingQueue;
}

+ (SQNetworkAgent *)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        _config = [SQNetworkConfig sharedInstance];
        _manager = [AFHTTPSessionManager manager];
        _requestsRecord = [M13MutableOrderedDictionary orderedDictionary];
        _manager.operationQueue.maxConcurrentOperationCount = SQSessionMaxConcurrentOperationCount;
        _manager.securityPolicy = _config.securityPolicy;
    }
    return self;
}

- (void)addRequest:(SQBaseRequest *)request
{
    [self requestServiceWith:request];
}

- (void)cancelRequest:(SQBaseRequest *)request {
    [request.requestOperation cancel];
    [self removeRequestInRecord:request];
    [request clearCompletionBlock];
}

- (void)cancelAllRequests {
    NSDictionary *copyRecord = [_requestsRecord copy];
    for (NSString *key in copyRecord)
    {
        SQBaseRequest *request = copyRecord[key];
        [request stop];
    }
}
#pragma mark - request
- (void)requestServiceWith:(SQBaseRequest*)request
{
    SQRequestMethod method = request.requestProtocol.method;//[request requestMethod];
    NSString *url = [self buildRequestUrl:request];
    id param = request.requestProtocol.requestArgument;
    AFConstructingBlock constructingBlock = [request constructingBlock];
    
    AFHTTPRequestSerializer *requestSerializer = nil;
    if (request.requestSerializerType == SQRequestSerializerTypeHTTP) {
        requestSerializer = [AFHTTPRequestSerializer serializer];
    } else if (request.requestSerializerType == SQRequestSerializerTypeJSON) {
        requestSerializer = [AFJSONRequestSerializer serializer];
    }
    //设置序列化方法block
    [requestSerializer setQueryStringSerializationWithBlock:request.requestSerializerBlock];
    
    requestSerializer.timeoutInterval = [request requestTimeoutInterval];
    //设置request的缓存模式
    requestSerializer.cachePolicy = request.requestProtocol.cachePolicy;
    
    // if api need server username and password
    NSArray *authorizationHeaderFieldArray = [request requestAuthorizationHeaderFieldArray];
    if (authorizationHeaderFieldArray != nil) {
        [requestSerializer setAuthorizationHeaderFieldWithUsername:(NSString *)authorizationHeaderFieldArray.firstObject
                                                          password:(NSString *)authorizationHeaderFieldArray.lastObject];
    }
    
    // if api need add custom value to HTTPHeaderField
    NSDictionary *headerFieldValueDictionary = [request requestHeaderFieldValueDictionary];
    if (headerFieldValueDictionary != nil) {
        for (id httpHeaderField in headerFieldValueDictionary.allKeys) {
            id value = headerFieldValueDictionary[httpHeaderField];
            if ([httpHeaderField isKindOfClass:[NSString class]] && [value isKindOfClass:[NSString class]]) {
                [requestSerializer setValue:(NSString *)value forHTTPHeaderField:(NSString *)httpHeaderField];
            } else {
                SQNLog(@"Error, class of key/value in headerFieldValueDictionary should be NSString.");
            }
        }
    }
    
    //序列化的配置参数
    _manager.requestSerializer = requestSerializer;
    // if api build custom url request
    NSURLRequest *customUrlRequest= [request buildCustomUrlRequest];
    if (customUrlRequest) {
        //自定义的URL请求对象的事件
        __weak typeof(self) wSelf = self;
        NSURLSessionTask *task = [_manager dataTaskWithRequest:customUrlRequest completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            if (!error || error == NULL)
            {
                //非错误
                [wSelf complete:request responseObject:responseObject];
            }
            else
            {
                //错误处理
                [wSelf failed:request error:error];
            }
        }];
        request.requestOperation = task;
        [task resume];
    } else {
        if (method == SQRequestMethodGet) {
            if (request.resumableDownloadPath) {
                //本地下载地址存在，就直接下载
                // add parameters to URL;
                NSString *filteredUrl = [SQNetworkPrivate urlStringWithOriginUrlString:url appendParameters:param];
                NSURLRequest *requestUrl = [NSURLRequest requestWithURL:[NSURL URLWithString:filteredUrl]];
                __weak typeof(self) wSelf = self;
                __block __weak NSURLSessionTask *task = [_manager downloadTaskWithRequest:requestUrl progress:^(NSProgress * _Nonnull downloadProgress) {
                    //进度处理
                } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                    NSURL *path = [NSURL fileURLWithPath:request.resumableDownloadPath];
                    return path;
                } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                    //结果处理
                    if (!error || error == NULL)
                    {
                        //下载完成后的对象为缓存地址
                        id responseObj = [NSString stringWithFormat:@"{'%@':'%@'}", KDownloadPathKey, filePath];
                        //非错误
                        [wSelf complete:request responseObject:responseObj];
                    }
                    else
                    {
                        //错误处理
                        [wSelf failed:request error:error];
                    }
                }];
                request.requestOperation = task;
                [task resume];
            } else {
                __weak typeof(self) wSelf = self;
                request.requestOperation = [_manager GET:url parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//                    [self handleRequestResult:task responseObject:responseObject];
                    [wSelf complete:request responseObject:responseObject];
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//                    [self handleRequestResult:task error:error];
                    [wSelf failed:request error:error];
                }];
            }
        } else if (method == SQRequestMethodPost) {
            if (constructingBlock != nil) {
                __weak typeof(self) wSelf = self;
                request.requestOperation = [_manager POST:url parameters:param constructingBodyWithBlock:constructingBlock progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//                    [self handleRequestResult:task responseObject:responseObject];
                    [wSelf complete:request responseObject:responseObject];
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//                    [self handleRequestResult:task error:error];
                    [wSelf failed:request error:error];
                }];
            } else {
                __weak typeof(self) wSelf = self;
                request.requestOperation = [_manager POST:url parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//                    [self handleRequestResult:task responseObject:responseObject];
                    [wSelf complete:request responseObject:responseObject];
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//                    [self handleRequestResult:task error:error];
                    [wSelf failed:request error:error];
                }];
            }
        }
        else if (method == SQRequestMethodHead)
        {
            __weak typeof(self) wSelf = self;
            request.requestOperation = [_manager HEAD:url parameters:param success:^(NSURLSessionDataTask * _Nonnull task) {
//                [self handleRequestResult:task responseObject:nil];
                [wSelf complete:request responseObject:nil];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//                [self handleRequestResult:task error:error];
                [wSelf failed:request error:error];
            }];
        }
        else if (method == SQRequestMethodPut)
        {
            __weak typeof(self) wSelf = self;
            request.requestOperation = [_manager PUT:url parameters:param success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//                [self handleRequestResult:task responseObject:responseObject];
                [wSelf complete:request responseObject:responseObject];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//                [self handleRequestResult:task error:error];
                [wSelf failed:request error:error];
            }];
        }
        else if (method == SQRequestMethodDelete)
        {
            __weak typeof(self) wSelf = self;
            request.requestOperation = [_manager DELETE:url parameters:param success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//                [self handleRequestResult:task responseObject:responseObject];
                [wSelf complete:request responseObject:responseObject];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//                [self handleRequestResult:task error:error];
                [wSelf failed:request error:error];
            }];
        }
        else if (method == SQRequestMethodPatch)
        {
            __weak typeof(self) wSelf = self;
            request.requestOperation = [_manager PATCH:url parameters:param success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//                [self handleRequestResult:task responseObject:responseObject];
                [wSelf complete:request responseObject:responseObject];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//                [self handleRequestResult:task error:error];
                [wSelf failed:request error:error];
            }];
        } else {
            SQNLog(@"Error, unsupport method type");
            return;
        }
    }
    
    // Set request operation priority
    switch (request.requestPriority) {
        case SQRequestPriorityHigh:
            request.requestOperation.priority = SQSessionTaskPriorityHigh;
            break;
        case SQRequestPriorityLow:
            request.requestOperation.priority = SQSessionTaskPriorityLow;
            break;
        case SQRequestPriorityDefault:
        default:
            request.requestOperation.priority = SQSessionTaskPriorityNormal;
            break;
    }
    
    // retain operation
    SQNLog(@"Add request: %@", NSStringFromClass([request class]));
    [self addRequestInRecord:request];
}

#pragma mark - build request url
- (NSString *)buildRequestUrl:(SQBaseRequest *)request
{
    NSString *detailUrl = request.requestProtocol.requestUrl;// [request requestUrl];
    if ([detailUrl hasPrefix:@"http"])
    {
        return detailUrl;
    }
    // filter url
    NSArray *filters = [_config urlFilters];
    for (id<SQUrlFilterProtocol> f in filters) {
        detailUrl = [f filterUrl:detailUrl withRequest:request];
    }
    
    NSString *tempBaseUrl = nil;
    BOOL cdnFlag = request.requestProtocol.isUseCND;
    NSString *cdnUrl = request.requestProtocol.cdnUrl;
    if (cdnFlag)
    {
        if (cdnUrl && cdnUrl.length > 0)
        {
            tempBaseUrl = cdnUrl;
        }
        else
        {
            tempBaseUrl = [_config cdnUrl];
        }
    }
    else
    {
        NSString *baseUrl = request.requestProtocol.baseUrl;
        if (baseUrl && baseUrl.length > 0)
        {
            tempBaseUrl = baseUrl;
        } else {
            tempBaseUrl = [_config baseUrl];
        }
    }
    return [NSString stringWithFormat:@"%@%@", tempBaseUrl, detailUrl];
}

#pragma mark - <SQRequestManagerDelegate>
//- (void)complete:(NSURLSessionTask *)task responseObject:(id)responseObject
//{
//    [self handleRequestResult:task responseObject:responseObject];
//}
//
//- (void)failed:(NSURLSessionTask *)task error:(NSError *)error
//{
//    [self handleRequestResult:task error:error];
//}

- (void)complete:(SQBaseRequest *)request responseObject:(id)responseObject
{
    [self handleRequestResult:request responseObject:responseObject];
}

- (void)failed:(SQBaseRequest *)request error:(NSError *)error
{
    [self handleRequestResult:request error:error];
}

#pragma mark - Private method

- (void)handleRequestResult:(SQBaseRequest *)request responseObject:(id)responseObject
{
//    SQBaseRequest *request = [self getRequestForOperation:operation];
    SQNLog(@"Finished Request: %@", NSStringFromClass([request class]));
    if (request)
    {
        //请求结果数据
        id responseObj = nil;
        if (responseObject)
        {
            responseObj = responseObject;
        }
        //检测结果是否正常
        BOOL succeed = [self checkResult:request responseObject:responseObj];
        if (succeed)
        {
            [request toggleAccessoriesWillStopCallBack];
            [request requestCompleteFilter];
            
            //结果实体数据封装
            //            SQResponseItem *resultData = [[SQResponseItem alloc] init];
            //解析结果数据
            NSData *responseData = nil;
            //            resultData.responseObject = responseObject;
            //            resultData.responseData = responseData;
            //resultData.isSuccess = succeed;
            //resultData.responseStatusCode = request.responseStatusCode;
            
            request.requestOperationError = nil;
            request.responseObject = responseObj;
            request.responseData = responseData;
            //代理回调
            if (request.delegate && [request.delegate respondsToSelector:@selector(requestFinished:)])
            {
                [request.delegate requestFinished:request];
            }
            //block回调
            if (request.successCompletionBlock)
            {
                request.successCompletionBlock(request);
            }
            [request toggleAccessoriesDidStopCallBack];
        }
        else
        {
            SQNLog(@"Request failed, status code = %ld", (long)request.responseStatusCode);
            responseObj = nil;
            [request toggleAccessoriesWillStopCallBack];
            [request requestFailedFilter];
            
            //错误信息
            NSInteger errorCode = request.responseStatusCode;
            NSError *failedError = [NSError errorWithDomain:KRequestErrorDomainKey code:errorCode userInfo:nil];
            request.requestOperationError = failedError;
            //代理回调
            if (request.delegate != nil && [request.delegate respondsToSelector:@selector(requestFailed:)])
            {
                [request.delegate requestFailed:request];
            }
            //block回调
            if (request.failureCompletionBlock)
            {
                request.failureCompletionBlock(request);
            }
            [request toggleAccessoriesDidStopCallBack];
        }
    }
//    [self removeOperation:operation];
    [self removeRequestInRecord:request];
    [request clearCompletionBlock];
}

- (void)handleRequestResult:(SQBaseRequest *)request error:(NSError *)error
{
//    SQBaseRequest *request = [self getRequestForOperation:operation];
    SQNLog(@"error Request: %@", NSStringFromClass([request class]));
    if (request) {
        SQNLog(@"Request failed, error: %@", error);
        [request toggleAccessoriesWillStopCallBack];
        [request requestFailedFilter];
        //错误信息
        NSInteger errorCode = error.code;
        NSDictionary *userInfo = error.userInfo;
        NSError *failedError = [NSError errorWithDomain:KRequestErrorDomainKey code:errorCode userInfo:userInfo];
        request.requestOperationError = failedError;
        if (request.delegate != nil && [request.delegate respondsToSelector:@selector(requestFailed:)])
        {
            [request.delegate requestFailed:request];
        }
        if (request.failureCompletionBlock) {
            request.failureCompletionBlock(request);
        }
        [request toggleAccessoriesDidStopCallBack];
    }
    //    [self removeOperation:operation];
    [self removeRequestInRecord:request];
    [request clearCompletionBlock];
}

- (BOOL)checkResult:(SQBaseRequest *)request responseObject:(id)responseObject
{
    BOOL result = [request statusCodeValidator];
    if (!result)
    {
        return result;
    }
    id validator = request.requestProtocol.jsonValidator;
    if (validator != nil)
    {
        id json = responseObject;
        result = [SQNetworkPrivate checkJson:json withValidator:validator];
    }
    return result;
}

////获取缓存的request
//- (SQBaseRequest*)getRequestForOperation:(NSURLSessionTask*)operation
//{
//    NSString *key = [self requestHashKey:operation];
//    SQBaseRequest *request = _requestsRecord[key];
//    return request;
//}

- (void)invokeAllDelegateWithErrorCode:(NSInteger)errorCode
{
    NSInteger numItems = [self countRequestInRecord];
    //    NSMutableArray *copyItems = [[NSMutableArray alloc] initWithCapacity:numItems];
    //
    //    //将Items复制下，防止一边回调一边被注销的情况发生。
    //    for (NSInteger i=0; i<numItems; ++i)
    //    {
    //        [copyItems addObject: [_items objectAtIndex:i]];
    //    }
    M13OrderedDictionary *copyItems = _requestsRecord.copy;
    for (NSInteger j=0; j<numItems; ++j)
    {
        SQBaseRequest *item = (SQBaseRequest *)[copyItems objectAtIndex:j];
        //失敗回調
        if ([item.delegate respondsToSelector:@selector(requestFailed:)])
        {
            [item.delegate requestFailed:item];
        }
        
        if (item.failureCompletionBlock)
        {
            item.failureCompletionBlock(item);
        }
    }
    //清理
    [_requestsRecord removeAllObjects];
}

#pragma mark - operation

//- (NSString *)requestHashKey:(NSURLSessionTask *)operation
//{
//    NSString *key = [NSString stringWithFormat:@"%lu", (unsigned long)[operation hash]];
//    return key;
//}
//
//- (void)addOperation:(SQBaseRequest *)request
//{
//    if (request.requestOperation != nil) {
//        NSString *key = [self requestHashKey:request.requestOperation];
//        @synchronized(self) {
//            [_requestsRecord addObject:request pairedWithKey:key];
//        }
//    }
//}
//
//- (void)removeOperation:(NSURLSessionTask *)operation
//{
//    NSString *key = [self requestHashKey:operation];
//    @synchronized(self) {
//        [_requestsRecord removeObjectForKey:key];
//    }
//    SQNLog(@"Request queue size = %lu", (unsigned long)[_requestsRecord count]);
//}

- (NSString *)requestInRecordHashKey:(SQBaseRequest *)request
{
    NSString *key = [NSString stringWithFormat:@"%lu", (unsigned long)request.hash];
    return key;
}

- (void)addRequestInRecord:(SQBaseRequest *)request
{
    NSString *key = [self requestInRecordHashKey:request];
    @synchronized(self) {
        [_requestsRecord addObject:request pairedWithKey:key];
    }
}

- (void)removeRequestInRecord:(SQBaseRequest *)request
{
    NSString *key = [self requestInRecordHashKey:request];
    @synchronized(self) {
        [_requestsRecord removeObjectForKey:key];
    }
    SQNLog(@"Request queue size = %lu", (unsigned long)[_requestsRecord count]);
}

- (NSInteger)countRequestInRecord
{
    return _requestsRecord.count;
}

- (SQBaseRequest*)requestInRecordAtIndex:(NSInteger)index
{
    SQBaseRequest *request = [_requestsRecord objectAtIndex:index];
    return request;
}
@end



