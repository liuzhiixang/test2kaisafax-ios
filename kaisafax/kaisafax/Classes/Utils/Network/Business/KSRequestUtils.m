//
//  KSRequestUtils.m
//  kaisafax
//
//  Created by semny on 17/5/9.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSRequestUtils.h"
#import "KSNWConfig.h"
#import "NSDate+Utilities.h"
#import "SQDeviceUtil.h"
#import "KSVersionMgr.h"
#import "KSUserMgr.h"
#import <NSHash/NSString+NSHash.h>
#import <CommonCrypto/CommonDigest.h>

@implementation KSRequestUtils
//创建请求参数(包括header)
+ (NSDictionary *)createArgumentWithTradeId:(NSString *)tradeId seqNo:(long long)seqNo data:(NSDictionary *)data1 error:(NSError **)error
{
    NSDictionary *bodyDict = data1;
    if (!tradeId || tradeId.length <= 0)
    {
        NSString *errorTitle = @"Request failed, request method error!";
        INFO(@"%@",errorTitle);
        
        //网络错误
        NSInteger errorCode = KSNW_RES_TRADEID_ERR;
        NSDictionary *errorinfo = @{KResultErrorMsgKey:errorTitle};
        if(error != NULL)
        {
            *error = [NSError errorWithDomain:KResultErrorDomain code:errorCode userInfo:errorinfo];
        }
        return nil;
    }
    
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] initWithCapacity:2];
    NSMutableDictionary *headDict = [NSMutableDictionary dictionary];
    /*---------------*/
    NSString *tradeIdStr = tradeId;
    //请求业务方法
    [headDict setObject:tradeIdStr forKey:kMethodKey];
    //接口版本
    [headDict setObject:kAPIVersionValue forKey:kVersionKey];
    //序列号，某次连接递增 客户端自行生成
    [headDict setObject:@(seqNo) forKey:kSeqNoKey];
    //时间戳(毫秒)
    NSDate *now = [NSDate date];
    //yyyy-MM-dd HH:mm:ss:SSS
    //long long timestamp = [now timeIntervalSince1970]*1000;
    NSString *timestamp = [now dateStringWithFormat:@"yyyy-MM-dd HH:mm:ss:SSS"];
    if (timestamp)
    {
        [headDict setObject:timestamp forKey:kTimestampKey];
    }
    
    //客户端应用ID 00001
    [headDict setObject:kAppKeyValue forKey:kAppKeyKey];
    //body压缩标志,默认 false不压缩；若压缩采用zip压缩方式
    //[headDict setObject:[NSNumber numberWithBool:NO] forKey:kIsCompressKey];
    
    //userID
    long long userId = [self getCurrentUserId];
    if (userId > 0)
    {
        [headDict setObject:@(userId) forKey:kUserIdKey];
    }
    
    // sessionid
    NSString *token = [self getCurrentToken];
    if (!token || token.length <= 0)
    {
        token = @"";
    }
    [headDict setObject:token forKey:kSessionIdKey];
    
    // guid
    NSString *guidStr = [self getCurrentGuid];
    if (!guidStr || guidStr.length <= 0)
    {
        guidStr = @"";
    }
    [headDict setObject:guidStr forKey:kGuidKey];
    
    //设备型号
    NSString *deviceModel = [SQDeviceUtil getDeviceModel];
    if (!deviceModel || deviceModel.length <= 0)
    {
        deviceModel = @"";
    }
    [headDict setObject:deviceModel forKey:kDeviceModelKey];
    //平台信息
    [headDict setObject:@(kPlatformTypeValue) forKey:kPlatformTypeKey];
    [headDict setObject:kChannelVID forKey:kAppChannelKey];
    
    //版本信息
    KSVersionMgr *versionMGR1 = [KSVersionMgr sharedInstance];
    NSString *versionName = [versionMGR1 getVersionName];
    if (versionName)
    {
        [headDict setObject:versionName forKey:kAppVersionKey];
    }
    //不在head里加，在需要版本序列号的接口（比如判断是否升级）里的body部分加上
    //    int versionCode = [versionMGR1 getAppVersion];
    //    if (versionCode>0)
    //    {
    //        [headDict setObject:@(versionCode) forKey:kVersionCodeKey];
    //    }
    //系统版本信息
    NSString *sysVersion = [SQDeviceUtil getSystemVersion];
    if (!sysVersion || sysVersion.length <= 0)
    {
        sysVersion = @"";
    }
    [headDict setObject:sysVersion forKey:kSysVersionKey];
    
    //校验数据（body部分有数据，必须校验）
    NSString *sign = [self encrypt:headDict body:data1];
    [headDict setObject:sign forKey:kSignKey];
    
    //直接放headDict/ bodydict到字典请求数据 AFN的x-www-form-urlencoded会解析为
    //body[mobile]=13149999999&body[type]=1&head[appChannel]=appstore&head[appKey]=00002&head[appVersion]=2.2.2
    //会带上两级标志，服务端暂时不识别
    NSString *headStr = [headDict yy_modelToJSONString];
    if (headStr)
    {
        //设置head
        [jsonDict setObject:headStr forKey:kHeadKey];
    }
    
    //请求参数转化
    //    NSData *requestData = nil;
    if (bodyDict && bodyDict.count > 0)
    {
        NSString *bodyStr = [bodyDict yy_modelToJSONString];
        //设置body数据
        if (bodyStr)
        {
            [jsonDict setObject:bodyStr forKey:kBodyKey];
        }
        //DEBUGG(@"%s, tradeId: %@ , requestArgument: %@", __FUNCTION__, tradeId,requestArgument);
    }
    DEBUGG(@"%s , %@", __FUNCTION__, jsonDict);
    return jsonDict;
}

+ (NSDictionary *)createPostArgumentWithTradeId:(NSString *)tradeId seqNo:(long long)seqNo data:(NSDictionary *)data1 error:(NSError **)error
{
    return [self createArgumentWithTradeId:tradeId seqNo:seqNo data:data1 error:error];
}

#pragma mark --------------内部方法----------------
/**
 *  获取当前用户的userid
 *
 *  @return 当前用户的userId
 */
+ (long long)getCurrentUserId
{
    long long userId = USER_MGR.user.user.userId;
    return userId;
}

/**
 *  获取当前用户登录后的token
 *
 *  @return 当前用户登录后的token
 */
+ (NSString *)getCurrentToken
{
    NSString *token = [USER_MGR getCurrentSessionId];
    return token;
}

//获取当前机器的guid
+ (NSString *)getCurrentGuid
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *guidStr = [userDefaults objectForKey:kUpdateDevInfoGUID];
    return guidStr;
}

+ (NSString *)encrypt:(NSDictionary *)header body:(NSDictionary *)body
{
    NSMutableDictionary *signDict = [NSMutableDictionary dictionary];
    if (header && header.count > 0)
    {
        [signDict addEntriesFromDictionary:header];
    }
    
    if (body && body.count > 0)
    {
        //签名增加body
        [signDict addEntriesFromDictionary:body];
    }
    
    if (!signDict || signDict.count <= 0)
    {
        return nil;
    }
    //排序
    NSArray *keys = [signDict allKeys];
    keys = [keys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        //obj1是从最后的数组元素开始；最终结果是A-Z，1-9；相当于实际的升序排序;
        return [obj1 compare:obj2]==NSOrderedDescending;
    }];
    
    //组装
    NSMutableString *signStr = [NSMutableString string];
    [signStr appendString:kAppSecret];
    [keys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id subObj = [signDict objectForKey:obj];
        [signStr appendString:obj];
        [signStr appendFormat:@"%@",subObj];
    }];
    [signStr appendString:kAppSecret];
    
    //DEBUGG(@"%s, %@",__FUNCTION__, signStr);
    
    //SHA1加密 16进制
    NSString *signStr1 = [self SHA1:signStr];
    
    return signStr1;
}

+ (NSString*) SHA1:(NSString *)string
{
    unsigned int outputLength = CC_SHA1_DIGEST_LENGTH;
    unsigned char output[outputLength];
    unsigned int length = (unsigned int) [string lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    CC_SHA1(string.UTF8String, length, output);
    return [self toHexString:output length:outputLength];;
}

+ (NSString*) toHexString:(unsigned char*) data length: (unsigned int) length {
    NSMutableString* hash = [NSMutableString stringWithCapacity:length * 2];
    for (unsigned int i = 0; i < length; i++) {
        [hash appendFormat:@"%02X", data[i]];
        data[i] = 0;
    }
    return hash;
}

@end
