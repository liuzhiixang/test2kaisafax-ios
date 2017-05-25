//
//  KSRequestBL
//  kaisafax
//
//  Created by semny on 15/10/10.
//  Copyright © 2015年 kaisafax. All rights reserved.
//

#import "KSRequestBL.h"
//#import "NSDate+Utilities.h"
//#import "SQDeviceUtil.h"
//#import "KSVersionMgr.h"
#import "KSUserMgr.h"
//#import <NSHash/NSString+NSHash.h>
//#import <CommonCrypto/CommonDigest.h>
#import "KSRequestUtils.h"


/**
 Returns a percent-escaped string following RFC 3986 for a query string key or value.
 RFC 3986 states that the following characters are "reserved" characters.
 - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
 - Sub-Delimiters: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="
 
 In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to allow
 query strings to include a URL. Therefore, all "reserved" characters with the exception of "?" and "/"
 should be percent-escaped in the query string.
 - parameter string: The string to be percent-escaped.
 - returns: The percent-escaped string.
 */
static NSString * SQPercentEscapedStringFromString(NSString *string) {
    static NSString * const kAFCharactersGeneralDelimitersToEncode = @":#[]@"; // does not include "?" or "/" due to RFC 3986 - Section 3.4
    static NSString * const kAFCharactersSubDelimitersToEncode = @"!$&'()*+,;=";
    
    NSMutableCharacterSet * allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [allowedCharacterSet removeCharactersInString:[kAFCharactersGeneralDelimitersToEncode stringByAppendingString:kAFCharactersSubDelimitersToEncode]];
    
    static NSUInteger const batchSize = 50;
    
    NSUInteger index = 0;
    NSMutableString *escaped = @"".mutableCopy;
    
    while (index < string.length) {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wgnu"
        NSUInteger length = MIN(string.length - index, batchSize);
#pragma GCC diagnostic pop
        NSRange range = NSMakeRange(index, length);
        
        // To avoid breaking up character sequences such as 👴🏻👮🏽
        range = [string rangeOfComposedCharacterSequencesForRange:range];
        
        NSString *substring = [string substringWithRange:range];
        NSString *encoded = [substring stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
        [escaped appendString:encoded];
        
        index += range.length;
    }
    
    return escaped;
}

#pragma mark ----数据匹配--------------
@interface SQQueryStringPair : NSObject
@property (readwrite, nonatomic, strong) id field;
@property (readwrite, nonatomic, strong) id value;

- (instancetype)initWithField:(id)field value:(id)value;

- (NSString *)URLEncodedStringValue;
@end

@implementation SQQueryStringPair

- (instancetype)initWithField:(id)field value:(id)value {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.field = field;
    self.value = value;
    
    return self;
}

- (NSString *)URLEncodedStringValue {
    if (!self.value || [self.value isEqual:[NSNull null]]) {
        return SQPercentEscapedStringFromString([self.field description]);
    } else {
        return [NSString stringWithFormat:@"%@=%@", SQPercentEscapedStringFromString([self.field description]), SQPercentEscapedStringFromString([self.value description])];
    }
}

@end

#pragma mark - query
FOUNDATION_EXPORT NSArray * SQQueryStringPairsFromDictionary(NSDictionary *dictionary);
FOUNDATION_EXPORT NSArray * SQQueryStringPairsFromKeyAndValue(NSString *key, id value);

static NSString * SQQueryStringFromParameters(NSDictionary *parameters) {
    NSMutableArray *mutablePairs = [NSMutableArray array];
    for (SQQueryStringPair *pair in SQQueryStringPairsFromDictionary(parameters)) {
        [mutablePairs addObject:[pair URLEncodedStringValue]];
    }
    
    return [mutablePairs componentsJoinedByString:@"&"];
}

NSArray * SQQueryStringPairsFromDictionary(NSDictionary *dictionary) {
    return SQQueryStringPairsFromKeyAndValue(nil, dictionary);
}

NSArray * SQQueryStringPairsFromKeyAndValue(NSString *key, id value) {
    NSMutableArray *mutableQueryStringComponents = [NSMutableArray array];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES selector:@selector(compare:)];
    
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = value;
        // Sort dictionary keys to ensure consistent ordering in query string, which is important when deserializing potentially ambiguous sequences, such as an array of dictionaries
        for (id nestedKey in [dictionary.allKeys sortedArrayUsingDescriptors:@[ sortDescriptor ]]) {
            id nestedValue = dictionary[nestedKey];
            if (nestedValue) {
                [mutableQueryStringComponents addObjectsFromArray:SQQueryStringPairsFromKeyAndValue((key ? [NSString stringWithFormat:@"%@[%@]", key, nestedKey] : nestedKey), nestedValue)];
            }
        }
    } else if ([value isKindOfClass:[NSArray class]]) {
        NSArray *array = value;
        for (id nestedValue in array) {
            [mutableQueryStringComponents addObjectsFromArray:SQQueryStringPairsFromKeyAndValue([NSString stringWithFormat:@"%@[]", key], nestedValue)];
        }
    } else if ([value isKindOfClass:[NSSet class]]) {
        NSSet *set = value;
        for (id obj in [set sortedArrayUsingDescriptors:@[ sortDescriptor ]]) {
            [mutableQueryStringComponents addObjectsFromArray:SQQueryStringPairsFromKeyAndValue(key, obj)];
        }
    } else {
        [mutableQueryStringComponents addObject:[[SQQueryStringPair alloc] initWithField:key value:value]];
    }
    
    return mutableQueryStringComponents;
}

@implementation KSRequestBL

//判断当前网络请求resp是下拉刷新 还是上拉加载更多
- (BOOL)isRefreshFromSeqNo:(long long)seqNo
{
    id seqData = [self objectInRecordStackForSeqno:seqNo];
    
    NSDictionary *dic = nil;
    BOOL isRefresh = NO;
    if (seqData && [seqData isKindOfClass:[NSDictionary class]])
    {
        dic = (NSDictionary *)seqData;
        NSNumber *refreshNum = [dic objectForKey:KRequestISRefreshKey];
        if (refreshNum)
        {
            isRefresh = [refreshNum boolValue];
        }
    }
    return isRefresh;
}

- (NSString *)getSearchTypeFromSeqNo:(long long)seqNo
{
    id seqData = [self objectInRecordStackForSeqno:seqNo];
    NSDictionary *dic = nil;
    NSString *searchType = nil;
    if (seqData && [seqData isKindOfClass:[NSDictionary class]])
    {
        dic = (NSDictionary *)seqData;
        searchType = [dic objectForKey:KRequestSearchType];
    }
    return searchType;
}

- (NSInteger)getPageIndexFromSeqNo:(long long)seqNo
{
    id seqData = [self objectInRecordStackForSeqno:seqNo];
    NSDictionary *dic = nil;
    NSInteger pageIndex = -1;
    if (seqData && [seqData isKindOfClass:[NSDictionary class]])
    {
        dic = (NSDictionary *)seqData;
        NSNumber *pageIndexNum = [dic objectForKey:KPageIndexKey];
        if (pageIndexNum)
        {
            pageIndex = pageIndexNum.integerValue;
        }
    }
    return pageIndex;
}

//TODO:服务端重构后的接口使用
//- (long long)requestWithTradeId:(NSString *)tradeId data:(NSDictionary *)data
//{
//    NSString *url = [self getAppServiceURL];
//    NSInteger method = SQRequestMethodPost;
//    return [self requestWithTradeId:tradeId data:data URL:url httpMethod:method cachePolicy:NSURLRequestReloadIgnoringCacheData];
//}

- (long long)requestWithTradeId:(NSString *)tradeId data:(NSDictionary *)data
{
    return [self requestWithTradeId:tradeId data:data updateSession:NO];
}

- (long long)requestWithTradeId:(NSString *)tradeId data:(NSDictionary *)data updateSession:(BOOL)updateSession
{
    return [self requestWithTradeId:tradeId data:data updateSession:updateSession delegate:self];
}

- (long long)requestWithTradeId:(NSString *)tradeId data:(NSDictionary *)data delegate:(id<SQRequestDelegate>)delegate
{
    NSString *url = SX_APP_API;
    NSInteger method = SQRequestMethodPost;
    long long seqNo = [self requestWithTradeId:tradeId data:data URL:url httpMethod:method updateSession:NO delegate:delegate];
    return seqNo;
}

- (long long)requestWithTradeId:(NSString *)tradeId data:(NSDictionary *)data updateSession:(BOOL)updateSession delegate:(id<SQRequestDelegate>)delegate
{
    NSString *url = SX_APP_API;
    NSInteger method = SQRequestMethodPost;
    long long seqNo = [self requestWithTradeId:tradeId data:data URL:url httpMethod:method updateSession:updateSession delegate:delegate];
    return seqNo;
}

//默认没有http缓存
- (long long)requestWithTradeId:(NSString *)tradeId data:(NSDictionary *)data URL:(NSString *)url httpMethod:(SQRequestMethod)method
{
    return [self requestWithTradeId:tradeId data:data URL:url httpMethod:method updateSession:NO];
}

- (long long)requestWithTradeId:(NSString *)tradeId data:(NSDictionary *)data URL:(NSString *)url httpMethod:(SQRequestMethod)method updateSession:(BOOL)updateSession
{
    return [self requestWithTradeId:tradeId data:data URL:url httpMethod:method updateSession:updateSession delegate:self];
}

- (long long)requestWithTradeId:(NSString *)tradeId data:(NSDictionary *)data URL:(NSString *)url httpMethod:(SQRequestMethod)method delegate:(id<SQRequestDelegate>)delegate
{
    return [self requestWithTradeId:tradeId data:data URL:url httpMethod:method updateSession:NO delegate:delegate];
}

- (long long)requestWithTradeId:(NSString *)tradeId data:(NSDictionary *)data URL:(NSString *)url httpMethod:(SQRequestMethod)method updateSession:(BOOL)updateSession delegate:(id<SQRequestDelegate>)delegate
{
    NSString *tradeIdStr = tradeId;
    return [self requestWithTradeId:tradeIdStr data:data URL:url httpMethod:method cachePolicy:NSURLRequestReloadIgnoringCacheData updateSession:updateSession delegate:delegate];
}

- (long long)requestWithTradeId:(NSString *)tradeId data:(NSDictionary *)data URL:(NSString *)url httpMethod:(SQRequestMethod)method cachePolicy:(NSURLRequestCachePolicy)cachePolicy updateSession:(BOOL)updateSession
{
    long long seqNo = [self requestWithTradeId:tradeId data:data URL:url httpMethod:method cachePolicy:cachePolicy updateSession:updateSession delegate:self];
    return seqNo;
}

- (long long)requestWithTradeId:(NSString *)tradeId data:(NSDictionary *)data URL:(NSString *)url httpMethod:(SQRequestMethod)method cachePolicy:(NSURLRequestCachePolicy)cachePolicy
{
    long long seqNo = [self requestWithTradeId:tradeId data:data URL:url httpMethod:method cachePolicy:cachePolicy updateSession:NO];
    return seqNo;
}

- (long long)requestWithTradeId:(NSString *)tradeId data:(NSDictionary *)data URL:(NSString *)url httpMethod:(SQRequestMethod)method cachePolicy:(NSURLRequestCachePolicy)cachePolicy updateSession:(BOOL)updateSession delegate:(id<SQRequestDelegate>)delegate
{
    if (method < 0)
    {
        method = SQRequestMethodGet;
    }
    
    //请求的最终报文
    //NSDictionary *requestArgument = nil;
    //请求序列号
    long long seqNo = [[KSSequenceNo sharedInstance] getSequenceNo];
    //请求即将处理的代理
    if (self.delegate && [self.delegate respondsToSelector:@selector(willHandle:)])
    {
        [self.delegate willHandle:self];
    }
    //请求即将处理的回调block
    if (self.willHandleBlock)
    {
        self.willHandleBlock(self);
    }
    
//    INFO(@"%s 222, seqNo: %ld, url: %@", __FUNCTION__, (long)seqNo, url);
    NSError *error = nil;
    KSBRequest *formDataRequest = [self createRequest:tradeId seqNo:seqNo data:data URL:url httpMethod:method cachePolicy:cachePolicy updateSession:updateSession error:&error];
    //创建对象错误回调
    if (error)
    {
        //错误信息
        self.error = error;
        NSInteger errorCode = error.code;
        //结果封装
        KSResponseEntity *responseEntity = [[KSResponseEntity alloc] init];
        responseEntity.tradeId = tradeId;
        responseEntity.sid = seqNo;
        [responseEntity setErrorCode:errorCode];
        
        //请求接口编号错误
        [self sysErrorCallbackWithResponse:responseEntity];
        return seqNo;
    }
    
    //设置代理
    [formDataRequest setDelegate:delegate];
    //开始请求
    [formDataRequest start];
    
    return seqNo;
}

//- (long long)requestWithTradeId:(NSString *)tradeId seqNo:(long long)seqNo request:(KSBRequest *)request
//{
//    NSInteger tmpSeqNo = seqNo;
//    //判断格式是否正确
//    if(!request || ![request isKindOfClass:[KSBRequest class]])
//    {
//        NSString *errorTitle = @"Request failed, request object format error!";
////        INFO(@"%@",errorTitle);
//        
//        //网络错误
//        NSInteger errorCode = KSNW_RES_UNKNOWN_ERR;
//        NSDictionary *errorinfo = @{KResultErrorMsgKey:errorTitle};
//        NSError *error = [NSError errorWithDomain:KResultErrorDomain code:errorCode userInfo:errorinfo];
//        self.error = error;
//        //结果封装
//        KSResponseEntity *responseEntity = [[KSResponseEntity alloc] init];
//        responseEntity.tradeId = tradeId;
//        responseEntity.sid = tmpSeqNo;
//        [responseEntity setErrorCode:errorCode];
//        
//        [self sysErrorCallbackWithResponse:responseEntity];
//        return tmpSeqNo;
//    }
//    
//    KSBRequest *brequest = request;
//    tmpSeqNo = brequest.sequenceID;
//    //判断tradeId是否一致
//    if (!tradeId || ![tradeId isEqualToString:brequest.tradeId])
//    {
//        NSString *errorTitle = @"Request failed, request tradeId error!";
//        INFO(@"%@",errorTitle);
//        //网络错误
//        NSInteger errorCode = KSNW_RES_UNKNOWN_ERR;
//        NSDictionary *errorinfo = @{KResultErrorMsgKey:errorTitle};
//        NSError *error = [NSError errorWithDomain:KResultErrorDomain code:errorCode userInfo:errorinfo];
//        self.error = error;
//        //结果封装
//        KSResponseEntity *responseEntity = [[KSResponseEntity alloc] init];
//        responseEntity.tradeId = tradeId;
//        responseEntity.sid = tmpSeqNo;
//        [responseEntity setErrorCode:errorCode];
//        
//        [self sysErrorCallbackWithResponse:responseEntity];
//        return tmpSeqNo;
//    }
//    
//    //判断请求的对象是否已经开启了
//    if (brequest.requestOperation)
//    {
//        //已经启动过了，不需要重复启动
//        INFO(@"Request has started!");
//        return tmpSeqNo;
//    }
//    
//    //设置代理
//    [brequest setDelegate:self];
//    //开始请求
//    [brequest start];
//    
//    return tmpSeqNo;
//}

- (KSBRequest *)createRequest:(NSString *)tradeId seqNo:(long long)seqNo data:(NSDictionary *)data1 URL:(NSString *)url httpMethod:(SQRequestMethod)method error:(NSError **)error
{
    return [self createRequest:tradeId seqNo:seqNo data:data1 URL:url httpMethod:method cachePolicy:NSURLRequestReloadIgnoringCacheData error:error];
}

/**
 *  @author semny
 *
 *  根据提供的参数创建默认的请求对象
 *
 *  @param tradeId      请求接口业务编号
 *  @param seqNo        序列号
 *  @param data         请求业务数据(body)1
 *  @param url          请求URL(字符串)
 *  @param method       请求方法(HTTP）
 *  @param cachePolicy  请求缓存模式
 *  @param error        错误
 *
 *  @return 请求对象≥≥≥≥≥≥≥≥≥≥.>>>.....
 */
- (KSBRequest *)createRequest:(NSString *)tradeId seqNo:(long long)seqNo data:(NSDictionary *)data1 URL:(NSString *)url httpMethod:(SQRequestMethod)method cachePolicy:(NSURLRequestCachePolicy)cachePolicy error:(NSError **)error
{
    return [self createRequest:tradeId seqNo:seqNo data:data1 URL:url httpMethod:method cachePolicy:cachePolicy updateSession:NO error:error];
}

- (KSBRequest *)createRequest:(NSString *)tradeId seqNo:(long long)seqNo data:(NSDictionary *)data1 URL:(NSString *)url httpMethod:(SQRequestMethod)method cachePolicy:(NSURLRequestCachePolicy)cachePolicy updateSession:(BOOL)updateSession error:(NSError **)error
{
    KSBRequest *formDataRequest = nil;
    if (!url)
    {
        NSString *errorTitle = @"Request failed, request url error!";
        INFO(@"%@",errorTitle);
        
        //网络错误
        NSInteger errorCode = KSNW_RES_URL_ERR;
        NSDictionary *errorinfo = @{KResultErrorMsgKey:errorTitle};
        if(error != NULL)
        {
            *error = [NSError errorWithDomain:KResultErrorDomain code:errorCode userInfo:errorinfo];
        }
        return formDataRequest;
    }
    NSDictionary *jsonDict = nil;
    NSData *requestData = nil;
    jsonDict = [self.class createPostArgumentWithTradeId:tradeId seqNo:seqNo data:data1 error:error];
    
    DEBUGG(@"%s , %@", __FUNCTION__, jsonDict);
    //    NSString *jsonStr = [self bv_jsonStringWithPrettyPrint:NO source:jsonDict]; //[jsonDict yy_modelToJSONString];
    requestData = [NSKeyedArchiver archivedDataWithRootObject:jsonDict];
    
    NSDictionary *head = [jsonDict objectForKey:kHeadKey];
    NSDictionary *body = data1;
    
    //加载新数据
    formDataRequest = [[KSBRequest alloc] initWithSequenceID:seqNo tradeId:tradeId header:head body:body updateSession:updateSession];
    [formDataRequest.requestProtocol setMethod:method];
    //数据格式（服务端使用的是form data的类型提交数据，数据格式还是json的 x-www-form-urlencoded）
    //    formDataRequest.requestSerializerType = SQRequestSerializerTypeJSON;
    formDataRequest.requestProtocol.cachePolicy = cachePolicy;
    
    //组合请求接口URL
    NSString *apiUrl = [NSString stringWithFormat:@"%@", url];
    [formDataRequest.requestProtocol setRequestUrl:apiUrl];
    //请求参数
    [formDataRequest.requestProtocol setData:requestData];
    [formDataRequest.requestProtocol setRequestArgument:jsonDict];
    
    //设置字符串序列化
    //    [formDataRequest setRequestSerializerBlock:^NSString * _Nonnull(NSURLRequest * _Nonnull request, id  _Nonnull parameters, NSError * _Nullable __autoreleasing * _Nullable error){
    //        NSString *query = nil;
    //        return query;
    //    }];
    return formDataRequest;
}

//创建请求参数(包括header)
+ (NSDictionary *)createArgumentWithTradeId:(NSString *)tradeId seqNo:(long long)seqNo data:(NSDictionary *)data1 error:(NSError **)error
{
    NSDictionary *jsonDict = [KSRequestUtils createArgumentWithTradeId:tradeId seqNo:seqNo data:data1 error:error];
    return jsonDict;
}

+ (NSDictionary *)createPostArgumentWithTradeId:(NSString *)tradeId seqNo:(long long)seqNo data:(NSDictionary *)data1 error:(NSError **)error
{
    return [self createArgumentWithTradeId:tradeId seqNo:seqNo data:data1 error:error];
}

+ (NSString *)createGetRequestURLWithTradeId:(NSString *)tradeId data:(NSDictionary *)data1 error:(NSError **)error
{
    long long seqNo = [[KSSequenceNo sharedInstance] getSequenceNo];
    //动态h5交互API，静态地址不一样
    NSString *urlStr = SX_APP_API;
    return [self createGetRequestURLWithURL:urlStr tradeId:tradeId seqNo:seqNo data:data1 error:error];
}

+ (NSString *)createGetRequestURLWithURL:(NSString*)url tradeId:(NSString *)tradeId seqNo:(long long)seqNo data:(NSDictionary *)data1 error:(NSError **)error
{
    NSString *jsonStr = nil;
    if (!url || url.length <= 0)
    {
        return nil;
    }
    NSDictionary *jsonDict = [self createArgumentWithTradeId:tradeId seqNo:seqNo data:data1 error:error];
    if (!jsonDict || jsonDict.count <= 0)
    {
        return jsonStr;
    }
    
    jsonStr = SQQueryStringFromParameters(jsonDict);
    //URL带参数
    NSString *urlStr = [NSString stringWithFormat:@"%@?%@", url, jsonStr];
    return urlStr;
}

#pragma mark -
#pragma mark ------------回调（子类没有实现，默认调用父类的回调）-----------
//成功代理回调 (默认为父类实现，子类可扩展)
- (void)succeedCallbackWithResponse:(KSResponseEntity*)responseEntity
{
    //DEBUGG(@"%s", __FUNCTION__);
    //回调处理
    if (SecureDelegateMethodJudger(self.delegate, finishedHandle:response:))
    {
        [self.delegate finishedHandle:self response:responseEntity];
    }
    
    //请求处理的回调block
    if (self.finishBlock)
    {
        self.finishBlock(self, responseEntity);
    }
    
    //移除请求序列号
    long long sid = responseEntity.sid;
    [self clearRecordStackBySeqno:sid];
}

//失败代理回调 (默认为父类实现，子类可扩展)
- (void)failedCallbackWithResponse:(KSResponseEntity*)responseEntity
{
    //DEBUGG(@"%s", __FUNCTION__);
    //回调处理
    if (SecureDelegateMethodJudger(self.delegate, failedHandle:response:))
    {
        [self.delegate failedHandle:self response:responseEntity];
    }
    
    //请求处理的回调block
    if (self.failedBlock)
    {
        self.failedBlock(self, responseEntity);
    }
    
    //移除请求序列号
    long long sid = responseEntity.sid;
    [self clearRecordStackBySeqno:sid];
}

//系统级别错误
- (void)sysErrorCallbackWithResponse:(KSResponseEntity *)responseEntity
{
    //DEBUGG(@"%s", __FUNCTION__);
    //回调处理
    if (SecureDelegateMethodJudger(self.delegate, sysErrorHandle:response:))
    {
        [self.delegate sysErrorHandle:self response:responseEntity];
    }
    
    //请求处理的回调block
    if (self.sysErrorBlock)
    {
        self.sysErrorBlock(self, responseEntity);
    }
    
    //移除请求序列号
    long long sid = responseEntity.sid;
    [self clearRecordStackBySeqno:sid];
}

#pragma mark - 数据解析相关
/**
 *  @author semny
 *
 *  解析请求返回结果
 *
 *  @param dict 返回的数据字典
 *  @param tradeId tradeId
 *
 *  @return 数据model/dict
 */
- (id)parserResponse:(NSDictionary *)dict withTradeId:(NSString *)tradeId
{
    if (!dict || dict.count <= 0 || !tradeId || tradeId.length <= 0)
    {
        return nil;
    }
    //model数据
    id model = [dict objectForKey:KResponseBodyKey];
    //解析数据
    Class classObj = [[KSAPIDataMgr sharedInstance] returnedClassBy:tradeId];
    id returnObj = model;
    
    if (!model)
    {
        return nil;
    }
    else if ([model isKindOfClass:[NSDictionary class]])
    {
        NSInteger count = ((NSDictionary*)model).count;
        if(count <= 0)
        {
            return nil;
        }
        
        if (classObj)
        {
            //dict类型
            returnObj = [classObj yy_modelWithDictionary:model];
        }
    }
    else if ([model isKindOfClass:[NSArray class]])
    {
        NSInteger count = ((NSArray*)model).count;
        if(count <= 0)
        {
            return nil;
        }
        if (classObj)
        {
            //数组类型
            returnObj = [NSArray yy_modelArrayWithClass:classObj json:model];
        }
    }
    
    return returnObj;
}

#pragma mark -
#pragma mark ---------------网络请求的公共回调处理----------------
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
            [self failedCallbackWithResponse:resp];
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
            [self failedCallbackWithResponse:resp];
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
            [self failedCallbackWithResponse:resp];
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
        [self succeedCallbackWithResponse:resp];
    }
    else
    {
        //数据解析错误,网络连接错误, 本地请求超时,未知错误
        if (errorCode == KSNW_RES_PARSER_ERR || errorCode == KSNW_RES_NETWORK_ERR || errorCode == KSNW_RES_TIMEOUT_ERR || errorCode == KSNW_RES_UNKNOWN_ERR)
        {
            ERROR(@"sysError! code:%ld", (long)errorCode);
            [self sysErrorCallbackWithResponse:resp];
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
            [self failedCallbackWithResponse:resp];
        }
    }
}

//网络层失败(超时,网络错误,未知错误)
- (void)requestFailed:(SQBaseRequest *)request
{
    ERROR(@"%s", __FUNCTION__);
    KSBRequest *brequest = nil;
    if ([request isKindOfClass:[KSBRequest class]])
    {
        brequest = (KSBRequest*)request;
    }
    NSString *tradeId = brequest.tradeId;
    ERROR(@"%s tradeId:%@", __FUNCTION__, tradeId);
    //子类处理
    KSResponseEntity *resp = [KSResponseEntity responseFromTradeId:tradeId sid:brequest.sequenceID body:nil];
    [self sysErrorCallbackWithResponse:resp];
}

@end
