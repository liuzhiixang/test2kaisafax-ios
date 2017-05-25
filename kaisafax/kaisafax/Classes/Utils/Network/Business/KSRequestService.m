//
//  KSRequestService.m
//  kaisafax
//
//  Created by semny on 17/5/8.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSRequestService.h"
#import "KSRequestUtils.h"
#import "KSSequenceNo.h"
#import "KSBRequest.h"
#import "KSConfig.h"
#import "KSUserMgr.h"

@interface KSRequestService()<SQRequestDelegate>

//@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, assign) BOOL isSessionIdReceived;
@property (nonatomic, assign) long long refreshRequestSeqID;
@property (nonatomic, assign) NSInteger retryNum;

@end

static NSInteger SESSION_RETRY_NUM = 3;

@implementation KSRequestService

+ (KSRequestService *)sharedService
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    if (self = [super init])
    {
//        _items = [[NSMutableArray alloc] init];
        _retryNum = SESSION_RETRY_NUM;
        _isSessionIdReceived = NO;
        _refreshRequestSeqID = -1;
        
        [self tryLoadSessionFromCache];
    }
    
    return self;
}

- (void)addRequest:(SQBaseRequest *)request
{
    if (!request)
    {
        return;
    }
    //添加到队列
//    [_items addObject:request];
    [self addRequestInRecord:request];
    
    KSBRequest *brequest = nil;
    BOOL updateSession = NO;
    if ([request isKindOfClass:[KSBRequest class]])
    {
        brequest = (KSBRequest*)request;
        updateSession = brequest.updateSession;
    }
    
    //未登录，需要更新session
    if (!USER_MGR.isLogin && updateSession)
    {
        [self sendRequestFromQueue];
    }
    else if (USER_MGR.isLogin && !_isSessionIdReceived)
    {
        //已经登录未发包
        [self sendRefreshRequestIfNeed];
    }
    else
    {
        [self sendRequestFromQueue];
    }
}

/**
 *  发送刷新包
 */
- (void)sendRefreshRequestIfNeed
{
    if (_refreshRequestSeqID >= 0)
    {
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *tradeId = KRefreshSessionIdTradeId;
    long long seqNo = [[KSSequenceNo sharedInstance] getSequenceNo];
    NSDictionary *jsonDict = [KSRequestUtils createArgumentWithTradeId:tradeId seqNo:seqNo data:params error:nil];
    NSData *requestData = [NSKeyedArchiver archivedDataWithRootObject:jsonDict];
    
    NSString *url = SX_APP_API;
    NSInteger method = SQRequestMethodPost;
    
    KSBRequest *formDataRequest = [[KSBRequest alloc] initWithSequenceID:seqNo tradeId:tradeId updateSession:YES];
    formDataRequest.delegate = self;
    [formDataRequest.requestProtocol setMethod:method];
    //数据格式（服务端使用的是form data的类型提交数据，数据格式还是json的 x-www-form-urlencoded）
    //    formDataRequest.requestSerializerType = SQRequestSerializerTypeJSON;
    formDataRequest.requestProtocol.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    //优先级
    formDataRequest.requestPriority = SQRequestPriorityHigh;
    //组合请求接口URL
    NSString *apiUrl = [NSString stringWithFormat:@"%@", url];
    [formDataRequest.requestProtocol setRequestUrl:apiUrl];
    //请求参数
    [formDataRequest.requestProtocol setData:requestData];
    [formDataRequest.requestProtocol setRequestArgument:jsonDict];
    [self requestServiceWith:formDataRequest];
    _refreshRequestSeqID = seqNo;
}

- (void)sendRequestFromQueue
{
    NSInteger numItems = [self countRequestInRecord];
    SQBaseRequest *item = nil;
    
    for (NSInteger i=0; i<numItems; ++i)
    {
        item = [self requestInRecordAtIndex:i]; 
        if (!item.isFinished && !item.isExecuting && !item.isCancelled)
        {
            item.sended = YES;
        }
        else if(!item.isSended)
        {
            [self requestServiceWith:item];
            item.sended = YES;
        }
        else if(!item.isSuspended)
        {
            item.sended = YES;
        }
    }
}

- (void)retryConnect
{
    if (_retryNum > 0)
    {
        _retryNum--;
        _refreshRequestSeqID = -1;
        _isSessionIdReceived = NO;
        [self sendRefreshRequestIfNeed];
    }
    else
    {
        //session請求次數超限
        [self invokeAllDelegateWithErrorCode:(NSInteger)KSNW_RES_INVALID_SESSIONID_ERR];
        _retryNum = SESSION_RETRY_NUM;
        _refreshRequestSeqID = -1;
        _isSessionIdReceived = NO;
    }
}

#pragma mark - Private Methods

- (void)tryLoadSessionFromCache
{
    if (!USER_MGR.isLogin)
    {
        return;
    }
    
    NSString *session = [self sessionFromCache];
    if (session != nil)
    {
        _isSessionIdReceived = YES;
    }
}

- (NSString *)sessionFromCache
{
//    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
//    id sessionValue = [userDefault objectForKey:KLoginUserEncryptedKey];
//    
//    if (sessionValue != nil && [sessionValue isKindOfClass:[NSString class]])
//    {
//        return (NSString *)sessionValue;
//    }
    NSString *sessionId = [USER_MGR getCurrentSessionId];
    return sessionId;
}

#pragma mark - -----------------私有补充方法---------------
/**
 *  产生临时秘钥
 *
 *  @return 临时秘钥
 */
- (NSString *)getTempKey
{
    // 产生临时密钥
    NSArray *numberArr = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"A", @"B", @"C", @"D", @"E", @"F"];
    NSMutableString *tempKeyStr = [[NSMutableString alloc] init];
    for (int i = 0; i < 16; i++)
    {
        [tempKeyStr appendString:numberArr[RandomNumber(0, 15)]];
    }
    return tempKeyStr;
}

//缓存零时秘钥
- (void)saveConnectionEncryptedKey:(NSString *)tempKey
{
    DEBUGG(@"%s tempKey is: %@",__FUNCTION__,tempKey);
    if (tempKey)
    {
        // 将生成的临时密钥保存到本地
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:tempKey forKey:KConnectionEncryptedKey];
        [userDefaults synchronize];
    }
}

- (NSString *)connectionEncryptedKeyFromCache
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    id sessionValue = [userDefault objectForKey:KConnectionEncryptedKey];
    
    if (sessionValue != nil && [sessionValue isKindOfClass:[NSString class]])
    {
        return (NSString *)sessionValue;
    }
    
    return nil;
}

//缓存session
- (void)saveConnectionSessionId:(NSString *)sessionId
{
    DEBUGG(@"%s sessionId is: %@",__FUNCTION__,sessionId);
    if (sessionId)
    {
        //存储sessionid数据，供整个请求会话生命周期使用
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:sessionId forKey:KConnectionSessionIdKey];
        [userDefaults synchronize];
    }
}

#pragma mark - request delegate
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
        
        //判断是不是session包
        KSBRequest *brequest = nil;
        BOOL sessionFlag = [self processSession:request responseObject:responseObj];
        if ([request isKindOfClass:[KSBRequest class]])
        {
            brequest = (KSBRequest*)request;
            long long sid = brequest.sequenceID;
            NSString *tradeId = brequest.tradeId;
            if (sid == _refreshRequestSeqID)
            {
                //包检测结果正常
                if(sessionFlag)
                {
                    //重试次数
                    _retryNum = SESSION_RETRY_NUM;
                    _isSessionIdReceived = YES;
                    //发送后续请求
                    [self sendRequestFromQueue];
                }
                else
                {
                    //重试
                    brequest.sended = NO;
                    [self retryConnect];
                }
                return;
            }
            else if([tradeId isEqualToString:KLoginTradeId] || [tradeId isEqualToString:KRegisterTradeId])
            {
                //注册，登录
                //包检测结果正常
                if(sessionFlag)
                {
                    //重试次数
                    _retryNum = SESSION_RETRY_NUM;
                    _isSessionIdReceived = YES;                }
            }
        }
        
        //检测结果是否正常
        BOOL succeed = [self checkResult:request responseObject:responseObj];
        //非session的请求回调
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
            
            //错误信息
            NSInteger errorCode = request.responseStatusCode;
            //session问题
            if (errorCode == KSNW_RES_INVALID_SESSIONID_ERR)
            {
                //登录状态才需要重发
                if (USER_MGR.isLogin)
                {
                    request.sended = NO;
                    [self retryConnect];
                    return;
                }
            }
            
            //正常情况和非session问题的回调
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
            
            //包异常
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
    if (request)
    {
        //判断是不是session包
        KSBRequest *brequest = nil;
        if ([request isKindOfClass:[KSBRequest class]])
        {
            brequest = (KSBRequest*)request;
            long long sid = brequest.sequenceID;
            if (sid == _refreshRequestSeqID)
            {
                brequest.sended = NO;
                [self retryConnect];
                return;
            }
        }
        
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

//处理首包请求的相关方法
- (BOOL)processSession:(SQBaseRequest*)request responseObject:(id)responseObject
{
    BOOL result = [self checkResult:request responseObject:responseObject];
    if (!result)
    {
        return result;
    }
    
    if (!responseObject || ![responseObject isKindOfClass:[NSDictionary class]])
    {
        return NO;
    }
    
    NSDictionary *dict = (NSDictionary*)responseObject;
    
    //session字符串
    NSString *sessionId = [[dict objectForKey:kBodyKey] objectForKey:kSessionIdKey];
    if(sessionId && sessionId.length > 0)
    {
        //更新session数据
        [self saveConnectionSessionId:sessionId];
        return YES;
    }
    
    return NO;
}
@end
