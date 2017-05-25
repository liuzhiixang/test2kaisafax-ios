//
//  KSBRequestBL.m
//  kaisafax
//
//  Created by semny on 16/7/18.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBRequestBL.h"
#import "KSBatchRequest.h"
#import "KSSequenceNo.h"
#import "KSUserMgr.h"

@interface KSBRequestBL()<SQBatchRequestDelegate>

@end

@implementation KSBRequestBL


- (long long)requestWithTradeId:(NSString *)tradeId array:(NSArray *)requestArray
{
    //请求序列号
    long long tmpSeqNo = [[KSSequenceNo sharedInstance] getSequenceNo];
    //请求即将处理的代理
    if (self.batchDelegate && [self.batchDelegate respondsToSelector:@selector(willBatchHandle:)])
    {
        [self.batchDelegate willBatchHandle:self];
    }
    //请求即将处理的回调block
    if (self.willHandleBBlock)
    {
        self.willHandleBBlock(self);
    }
    
    NSArray *reqArray = requestArray;
    NSString *tTradeId = tradeId;
    //判断tradeId是否一致
    if (!tTradeId || tTradeId.length <= 0)
    {
        NSString *errorTitle = @"Request failed, request tradeId error!";
        INFO(@"%@",errorTitle);
        //网络错误
        NSInteger errorCode = KSNW_RES_UNKNOWN_ERR;
        NSDictionary *errorinfo = @{KResultErrorMsgKey:errorTitle};
        NSError *error = [NSError errorWithDomain:KResultErrorDomain code:errorCode userInfo:errorinfo];
        self.error = error;
        //结果封装
        KSResponseEntity *responseEntity = [[KSResponseEntity alloc] init];
        responseEntity.tradeId = tTradeId;
        responseEntity.sid = tmpSeqNo;
        [responseEntity setErrorCode:errorCode];
        
        [self failedBatchCallbackWithResponse:responseEntity];
        return tmpSeqNo;
    }
    
    //判断分支请求数组是否正常
    if (!reqArray || reqArray.count <= 0)
    {
        NSString *errorTitle = @"Batch Request failed, branch request data error!";
        INFO(@"%@",errorTitle);
        //网络错误
        NSInteger errorCode = KSNW_RES_UNKNOWN_ERR;
        NSDictionary *errorinfo = @{KResultErrorMsgKey:errorTitle};
        NSError *error = [NSError errorWithDomain:KResultErrorDomain code:errorCode userInfo:errorinfo];
        self.error = error;
        //结果封装
        KSResponseEntity *responseEntity = [[KSResponseEntity alloc] init];
        responseEntity.tradeId = tTradeId;
        responseEntity.sid = tmpSeqNo;
        [responseEntity setErrorCode:errorCode];
        
        [self failedBatchCallbackWithResponse:responseEntity];
        return tmpSeqNo;
    }
    
    //组合请求
    KSBatchRequest *homeRequest = [[KSBatchRequest alloc] initWithSequenceID:tmpSeqNo tradeId:tTradeId requestArray:reqArray];
    homeRequest.delegate = self;
    //开启请求
    [homeRequest start];
    return tmpSeqNo;
}

#pragma mark - Batch request delegate
- (void)batchRequestFinished:(SQBatchRequest *)batchRequest
{
    //请求完成的处理
    KSBatchRequest *brequest = nil;
    if ([batchRequest isKindOfClass:[KSBatchRequest class]])
    {
        brequest = (KSBatchRequest*)batchRequest;
    }
    NSString *tradeId = brequest.tradeId;
    //DEBUGG(@"%s, tradeId: %@", __FUNCTION__, tradeId);
    //子类处理
    KSResponseEntity *resp = [KSResponseEntity responseFromTradeId:tradeId sid:brequest.sequenceID body:nil];
    [self succeedBatchCallbackWithResponse:resp];
}

- (void)batchRequestFailed:(SQBatchRequest *)batchRequest
{
    //请求失败的处理
    KSBatchRequest *brequest = nil;
    if ([batchRequest isKindOfClass:[KSBatchRequest class]])
    {
        brequest = (KSBatchRequest*)batchRequest;
    }
    NSString *tradeId = brequest.tradeId;
    //DEBUGG(@"%s, tradeId: %@", __FUNCTION__, tradeId);
    //子类处理
    KSResponseEntity *resp = [KSResponseEntity responseFromTradeId:tradeId sid:brequest.sequenceID body:nil];
    [self failedBatchCallbackWithResponse:resp];
}

- (void)batchRequestExecuting:(SQBatchRequest *)batchRequest finishRequest:(SQBaseRequest *)itemRequest
{
    //Batch请求过程中的每个阶段的请求
    KSBRequest *brequest = nil;
    NSString *tradeId = nil;
    if (itemRequest && [itemRequest isKindOfClass:[KSBRequest class]])
    {
        brequest = (KSBRequest*)itemRequest;
        tradeId = brequest.tradeId;
    }
    
    //DEBUGG(@"%s tradeId:%@", __FUNCTION__, tradeId);
    //报文结果
    id responseObj = brequest.responseObject;
    NSDictionary *dict = nil;
    NSInteger errorCode = KSNW_RES_SUCCESS;
    
    //请求结果封装
    KSResponseEntity *resp = [KSResponseEntity responseFromTradeId:tradeId sid:brequest.sequenceID body:nil];
    
    DEBUGG(@"%s , %@", __FUNCTION__, responseObj);
    
    //判断错误码
    if (responseObj && [responseObj isKindOfClass:[NSDictionary class]])
    {
        dict = (NSDictionary *)responseObj;
        //head数据
        NSDictionary *headDict = [dict objectForKey:KResponseHeadKey];
        if (!headDict || ![headDict isKindOfClass:[NSDictionary class]] || headDict.count <= 0)
        {
            errorCode = KSNW_RES_MISS_PARAMS_ERR;
            //错误码
            resp.errorCode = errorCode;
            [self failedItemBatchCallbackWithResponse:resp];
            return;
        }
        
        //请求方法
        NSString *method = [dict objectForKey:KResponseMethodKey];
        if (method && ![method isEqualToString:tradeId])
        {
            //失败不存在错误码 或格式不对
            errorCode = KSNW_RES_TRADEID_ERR;
            //错误码
            resp.errorCode = errorCode;
            [self failedItemBatchCallbackWithResponse:resp];
            return;
        }
        
        //错误码，错误信息
        NSNumber *errorCodeNum = [headDict objectForKey:KResponseErrorCodeKey];
        NSString *msg = [headDict objectForKey:KResponseErrorMsgKey];
        resp.errorDescription = msg;
        //不存在错误码
        if (!errorCodeNum || ![errorCodeNum isKindOfClass:[NSNumber class]])
        {
            //失败不存在错误码
            errorCode = KSNW_RES_MISS_PARAMS_ERR;
            //错误码
            resp.errorCode = errorCode;
            [self failedItemBatchCallbackWithResponse:resp];
            return;
        }
        
        //真实错误码
        errorCode =  errorCodeNum.longValue;
        //判断错误码的错误性质，errorCode<0 本地相关错误; errorCode==0 成功; errorCode>0 && errorCode <=10000开发错误; errorCode>10000 业务错误
        if (errorCode > KSNW_RES_SUCCESS && errorCode <= KSNW_RES_REQUEST_BUSSINESS_ERR)
        {
            //错误信息显示默认的
            resp.errorDescription = KRequestFailedMsgText;
        }
        
        //model数据
        id returnObj = [self parserResponse:dict withTradeId:tradeId];
        //有配置就直接使用model的json解析，没配置就得手动解析
        resp.body = returnObj;
    }
    else
    {
        errorCode = KSNW_RES_UNKNOWN_ERR;
        //错误码
        resp.errorCode = errorCode;
        NSString *msg = KRequestUnknowErrorMessage;
        resp.errorDescription = msg;
    }
    
    //DEBUGG(@"%s result: %@", __FUNCTION__, dict);
    //错误码
    resp.errorCode = errorCode;
    //判断请求是否成功
    if(errorCode == KSNW_RES_SUCCESS)
    {
        //成功
        [self succeedItemBatchCallbackWithResponse:resp];
    }
    else
    {
        //数据解析错误,网络连接错误, 本地请求超时,未知错误
        if (errorCode == KSNW_RES_PARSER_ERR || errorCode == KSNW_RES_NETWORK_ERR || errorCode == KSNW_RES_TIMEOUT_ERR || errorCode == KSNW_RES_UNKNOWN_ERR)
        {
            ERROR(@"sysError! code:%ld", (long)errorCode);
            [self sysErrorItemBatchCallbackWithResponse:resp];
        }
        else
        {
            //判断登陆态的错误
            if (errorCode == KSNW_RES_INVALID_SESSIONID_ERR)
            {
                BOOL isLogin = [USER_MGR isLogin];
                if (isLogin)
                {
                    //没有权限，进行token登录
                }
                //发出登录权限错误或者未登录的通知
                [USER_MGR handleLoginStateInvalid:LoginPathInProcess loginType:LoginTypeByRegister];
            }
            //业务型的错误
            ERROR(@"business Error! code:%ld",(long)errorCode);
            [self failedItemBatchCallbackWithResponse:resp];
        }
    }
}

- (void)batchRequestExecuting:(SQBatchRequest *)batchRequest failureRequest:(SQBaseRequest *)itemRequest
{
    //Batch请求过程中的每个阶段的请求
    KSBRequest *brequest = nil;
    if ([itemRequest isKindOfClass:[KSBRequest class]])
    {
        brequest = (KSBRequest*)itemRequest;
    }
    NSString *tradeId = brequest.tradeId;
    //DEBUGG(@"%s, tradeId: %@", __FUNCTION__, tradeId);
    //子类处理
    KSResponseEntity *resp = [KSResponseEntity responseFromTradeId:tradeId sid:brequest.sequenceID body:nil];
    [self sysErrorItemBatchCallbackWithResponse:resp];
}

#pragma mark -
#pragma mark ---------------网络请求的公共回调处理(单个的网络请求处理)----------------
//网络层成功
- (void)requestFinished:(SQBaseRequest *)request
{
    KSBRequest *brequest = nil;
    NSString *tradeId = nil;
    if (request && [request isKindOfClass:[KSBRequest class]])
    {
        brequest = (KSBRequest*)request;
        tradeId = brequest.tradeId;
    }
    
    //DEBUGG(@"%s tradeId:%@", __FUNCTION__, tradeId);
    //报文结果
    id responseObj = request.responseObject;
    NSDictionary *dict = nil;
    NSInteger errorCode = KSNW_RES_SUCCESS;
    
    //请求结果封装
    KSResponseEntity *resp = [KSResponseEntity responseFromTradeId:tradeId sid:brequest.sequenceID body:nil];
    
    DEBUGG(@"%s , %@", __FUNCTION__, responseObj);
    
    //判断错误码
    if (responseObj && [responseObj isKindOfClass:[NSDictionary class]])
    {
        dict = (NSDictionary *)responseObj;
        //head数据
        NSDictionary *headDict = [dict objectForKey:KResponseHeadKey];
        if (!headDict || ![headDict isKindOfClass:[NSDictionary class]] || headDict.count <= 0)
        {
            errorCode = KSNW_RES_MISS_PARAMS_ERR;
            //错误码
            resp.errorCode = errorCode;
            [self failedItemBatchCallbackWithResponse:resp];
            return;
        }
        
        //请求方法
        NSString *method = [dict objectForKey:KResponseMethodKey];
        if (method && ![method isEqualToString:tradeId])
        {
            //失败不存在错误码 或格式不对
            errorCode = KSNW_RES_TRADEID_ERR;
            //错误码
            resp.errorCode = errorCode;
            [self failedItemBatchCallbackWithResponse:resp];
            return;
        }
        
        //错误码，错误信息
        NSNumber *errorCodeNum = [headDict objectForKey:KResponseErrorCodeKey];
        NSString *msg = [headDict objectForKey:KResponseErrorMsgKey];
        resp.errorDescription = msg;
        //不存在错误码
        if (!errorCodeNum || ![errorCodeNum isKindOfClass:[NSNumber class]])
        {
            //失败不存在错误码
            errorCode = KSNW_RES_MISS_PARAMS_ERR;
            //错误码
            resp.errorCode = errorCode;
            [self failedItemBatchCallbackWithResponse:resp];
            return;
        }
        
        //真实错误码
        errorCode =  errorCodeNum.longValue;
        //model数据
        id returnObj = [self parserResponse:dict withTradeId:tradeId];
        //有配置就直接使用model的json解析，没配置就得手动解析
        resp.body = returnObj;
    }
    else
    {
        errorCode = KSNW_RES_UNKNOWN_ERR;
        //错误码
        resp.errorCode = errorCode;
        NSString *msg = KRequestUnknowErrorMessage;
        resp.errorDescription = msg;
    }
    
    //DEBUGG(@"%s result: %@", __FUNCTION__, dict);
    //错误码
    resp.errorCode = errorCode;
    //判断请求是否成功
    if(errorCode == KSNW_RES_SUCCESS)
    {
        //成功
        [self succeedItemBatchCallbackWithResponse:resp];
    }
    else
    {
        //数据解析错误,网络连接错误, 本地请求超时,未知错误
        if (errorCode == KSNW_RES_PARSER_ERR || errorCode == KSNW_RES_NETWORK_ERR || errorCode == KSNW_RES_TIMEOUT_ERR || errorCode == KSNW_RES_UNKNOWN_ERR)
        {
            ERROR(@"sysError! code:%ld", (long)errorCode);
            [self sysErrorItemBatchCallbackWithResponse:resp];
        }
        else
        {
            //判断登陆态的错误
            if (errorCode == KSNW_RES_INVALID_SESSIONID_ERR)
            {
                BOOL isLogin = [USER_MGR isLogin];
                if (isLogin)
                {
                    //没有权限，进行token登录
                }
                //发出登录权限错误或者未登录的通知
                [USER_MGR handleLoginStateInvalid:LoginPathInProcess loginType:LoginTypeByRegister];
            }
            //业务型的错误
            ERROR(@"business Error! code:%ld",(long)errorCode);
            [self failedItemBatchCallbackWithResponse:resp];
        }
    }
}

//网络层失败(超时,网络错误,未知错误)
- (void)requestFailed:(SQBaseRequest *)request
{
    //DEBUGG(@"%s", __FUNCTION__);
    KSBRequest *brequest = nil;
    if ([request isKindOfClass:[KSBRequest class]])
    {
        brequest = (KSBRequest*)request;
    }
    NSString *tradeId = brequest.tradeId;
    //子类处理
    KSResponseEntity *resp = [KSResponseEntity responseFromTradeId:tradeId sid:brequest.sequenceID body:nil];
    [self sysErrorItemBatchCallbackWithResponse:resp];
}


#pragma mark -
#pragma mark -----------通知结果处理(网络请求回调使用)--------------
/**
 *  分支请求的回调
 */
//成功代理回调 (默认为父类实现，子类可扩展)
- (void)succeedItemBatchCallbackWithResponse:(KSResponseEntity*)responseEntity
{
    //DEBUGG(@"%s", __FUNCTION__);
    //回调处理
    if (SecureDelegateMethodJudger(self.batchDelegate, finishBatchHandle:itemResponse:))
    {
        [self.batchDelegate finishBatchHandle:self itemResponse:responseEntity];
    }
    
    //请求处理的回调block
    if (self.finishBBlock)
    {
        self.finishBBlock(self, responseEntity);
    }
    
    //移除请求序列号
    long long sid = responseEntity.sid;
    [self clearRecordStackBySeqno:sid];
}

//失败代理回调 (默认为父类实现，子类可扩展)
- (void)failedItemBatchCallbackWithResponse:(KSResponseEntity*)responseEntity
{
    ERROR(@"%s", __FUNCTION__);
    //回调处理
    if (SecureDelegateMethodJudger(self.batchDelegate, failedBatchHandle:itemResponse:))
    {
        [self.batchDelegate failedBatchHandle:self itemResponse:responseEntity];
    }
    
    //请求处理的回调block
    if (self.failedBBlock)
    {
        self.failedBBlock(self, responseEntity);
    }
    
    //移除请求序列号
    long long sid = responseEntity.sid;
    [self clearRecordStackBySeqno:sid];
}

//系统级的错误
- (void)sysErrorItemBatchCallbackWithResponse:(KSResponseEntity*)responseEntity
{
    ERROR(@"%s", __FUNCTION__);
    //回调处理
    if (SecureDelegateMethodJudger(self.batchDelegate, sysErrorBatchHandle:itemResponse:))
    {
        [self.batchDelegate sysErrorBatchHandle:self itemResponse:responseEntity];
    }
    
    //请求处理的回调block
    if (self.sysErrorBBlock)
    {
        self.sysErrorBBlock(self, responseEntity);
    }
    
    //移除请求序列号
    long long sid = responseEntity.sid;
    [self clearRecordStackBySeqno:sid];
}

/**
 *  整个batch的回调
 */
//成功代理回调 (默认为父类实现，子类可扩展)
- (void)succeedBatchCallbackWithResponse:(KSResponseEntity*)responseEntity
{
    //DEBUGG(@"%s", __FUNCTION__);
    //回调处理
    if (SecureDelegateMethodJudger(self.batchDelegate, finishBatchHandle:))
    {
        [self.batchDelegate finishBatchHandle:self];
    }
    
    //请求处理的回调block
    if (self.finishHandleBBlock)
    {
        self.finishHandleBBlock(self);
    }
    
    //移除请求序列号
    long long sid = responseEntity.sid;
    [self clearRecordStackBySeqno:sid];
}

//失败代理回调 (默认为父类实现，子类可扩展)
- (void)failedBatchCallbackWithResponse:(KSResponseEntity*)responseEntity
{
    ERROR(@"%s", __FUNCTION__);
    //回调处理
    if (SecureDelegateMethodJudger(self.batchDelegate, failedBatchHandle:))
    {
        [self.batchDelegate failedBatchHandle:self];
    }
    
    //请求处理的回调block
    if (self.failedHandleBBlock)
    {
        self.failedHandleBBlock(self);
    }
    
    //移除请求序列号
    long long sid = responseEntity.sid;
    [self clearRecordStackBySeqno:sid];
}

#pragma mark - 老的回调方法
- (void)succeedCallbackWithResponse:(KSResponseEntity *)responseEntity __deprecated_msg("Method deprecated. Batch请求BL中使用succeedItemBatchCallbackWithResponse")
{
    [super succeedCallbackWithResponse:responseEntity];
}

- (void)failedCallbackWithResponse:(KSResponseEntity *)responseEntity __deprecated_msg("Method deprecated. Batch请求BL中使用failedItemBatchCallbackWithResponse")
{
    [super failedCallbackWithResponse:responseEntity];
}

- (void)sysErrorCallbackWithResponse:(KSResponseEntity *)responseEntity __deprecated_msg("Method deprecated. Batch请求BL中使用sysErrorItemBatchCallbackWithResponse")
{
    [super sysErrorCallbackWithResponse:responseEntity];
}
@end
