//
//  SocialAPISinaWeibo.m
//  
//
//  Created by Semny on 14-9-23.
//  Copyright (c) 2014年 Semny. All rights reserved.
//

#import "SocialAPISinaWeibo.h"
#import "SocialSequenceNo.h"
#import "NSDate+Utilities.h"

#define KSinaWeiboRequestKey    @"SWRequestKey"
//#define kSinaWeiboSSOLoginRequestTag      @"SWSSO"
////分享的时候需要更新token的标志
//#define kSinaWeiboShareRequestTag      @"SWShare"
////获取用户信息的时候需要更新token的标志
//#define KSinaWeiboUserInfoKey   @"SWUserInfo"

//分享工具相关
#define KNoticeTitle  NSLocalizedString(@"NoticeTitle",@"Notice")
#define KShareSuccessTitle  NSLocalizedString(@"ShareSuccessTitle",@"Shared success")
#define KShareFailedTitle  NSLocalizedString(@"ShareFailedTitle",@"Shared Failed")


@interface SocialAPISinaWeibo () < WBHttpRequestDelegate> {
    
}
//静态配置文件
@property (retain, nonatomic) NSDictionary *configDict;
@property (retain, nonatomic) NSDictionary *shareParamDict;
//分享内容
@property (retain, nonatomic) SocialEntity *shareContent;

/**
 *  认证的token
 */
@property (copy, nonatomic) NSString *accessToken;
//新浪用户id
@property (copy, nonatomic) NSString *userID;
//超时时间
@property (retain, nonatomic) NSDate *expirationDate;

@end

@implementation SocialAPISinaWeibo

- (instancetype)initWith:(NSDictionary *)userInfo
{
    self = [super init];
    if (self)
    {
        _configDict = self.platformsConfigDic[@"SinaWeibo"];
        //检测新浪用户信息是否有效
        if (userInfo && userInfo.count > 0)
        {
            NSString *swAccessToken = [userInfo objectForKey:KSinaWeiboAccessToken];
            NSString *swUserID = [userInfo objectForKey:KSinaWeiboUserId];
            NSDate  *swExpirationDateValue = [userInfo objectForKey:KSinaWeiboExpirationDate];
            NSDate *nowDate = [NSDate date];
            if (swAccessToken && swAccessToken.length > 0 && swUserID && swUserID.length > 0 && [nowDate isLaterThanDate:swExpirationDateValue])
            {
                _accessToken = swAccessToken;
                _userID = swUserID;
                _expirationDate = swExpirationDateValue;
            }
        }
    }
    return self;
}

- (instancetype)initWith:(NSDictionary *)userInfo delegate:(id<WBHttpRequestDelegate>)delegate
{
    self = [self init];
    if (self)
    {
        //_httpDelegate = delegate;
    }
    return self;
}

- (void)registerApp
{
    [WeiboSDK enableDebugMode:_enableDebugMode];
    if ([WeiboSDK registerApp:_configDict[@"AppKey"]] == NO) {
        NSLog(@"===新浪微博注册失败===");
    }
}

- (BOOL)isWeiboInstalled
{
    return [WeiboSDK isWeiboAppInstalled];
}

/**
 *  检测用户信息是否有效，token是否有效
 *
 *  @return YES:有效；NO:无效；
 */
- (BOOL)checkUserInfo
{
    BOOL flag = YES;
    
    NSDate *nowDate = [NSDate date];
    //是否过期
    BOOL noExpiration = [nowDate isEarlierThanDate:_expirationDate];
    if (!_accessToken || _accessToken.length <= 0 || !_userID || _userID.length <= 0 || !noExpiration)
    {
        [self clearSinaWeiboUserInfo:NO];
        flag = NO;
    }
    return flag;
}

/**
 *  清理新浪用户信息
 */
- (void)clearSinaWeiboUserInfo:(BOOL)clearAll
{
    _accessToken = nil;
    _userID = nil;
    _expirationDate = nil;
    if (clearAll)
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults removeObjectForKey:KSinaWeiboUserInfo];
        [userDefaults synchronize];
    }
}

#pragma mark -
#pragma mark ------------Sina用户及注册登录相关-----------
/**
 *  根据父流程的请求类型编号和序列号获取用户信息
 *
 *  @param pCmdId 父流程的请求类型编号
 *  @param pSeqNo 父流程的请求序列号
 *
 *  @return 当前接口请求的序列号
 */
- (long)getUserInfo:(NSInteger)pCmdId processSeqNo:(long)pSeqNo
{
    long seqNo = -1;
    BOOL flag = [self checkUserInfo];
    if (flag)
    {
        seqNo =[self getSWUserInfoBy:pCmdId processSeqNo:pSeqNo];
    }
    else
    {
        seqNo = [self ssoLoginBy:kSinaWeiboGetUserSSOLoginRequestTag];
    }
    return seqNo;
}

/**
 *  获取新浪的用户信息(单独流程，不用在其他流程中使用，没有判断用户token是否需要登录)
 *
 *  @return 新浪用户信息请求的序列号
 */
- (long)getUserInfo
{
    long seqNo = -1;
    BOOL flag = [self checkUserInfo];
    if (flag)
    {
        seqNo =[self getSWUserInfo];
    }
    else
    {
        seqNo = [self ssoLoginBy:kSinaWeiboGetUserSSOLoginRequestTag];
    }
    return seqNo;
}

//- (long)getUserInfo:(NSString *)requestTag
//{
//    long seqNo = -1;
//    BOOL flag = [self checkUserInfo];
//    if (flag)
//    {
//        seqNo =[self getSWUserInfoBy:requestTag];
//    }
//    else
//    {
//        seqNo = [self ssoLoginBy:kSinaWeiboGetUserSSOLoginRequestTag];
//    }
//    return seqNo;
//}

/**
 *  根据父流程的请求类型编号和序列号获取用户信息(没有判断用户token是否需要登录)
 *
 *  @param pCmdId 父流程的请求类型编号
 *  @param pSeqNo 父流程的请求序列号
 *
 *  @return 当前接口请求的序列号
 */
- (long)getSWUserInfoBy:(NSInteger)pCmdId processSeqNo:(long)pSeqNo
{
    long seqNo = -1;
    SocialSequenceNo *seqObj = [SocialSequenceNo sharedInstance];
    seqNo = seqObj.sequenceNo;
    [self getSWUserInfo:seqNo requestTag:nil processCmdId:pCmdId processSeqNo:pSeqNo];
    return seqNo;
}

/**
 *  获取新浪的用户信息(单独流程，不用在其他流程中使用，没有判断用户token是否需要登录)
 *
 *  @return 新浪用户信息请求的序列号
 */
- (long)getSWUserInfo
{
    long seqNo = -1;
    SocialSequenceNo *seqObj = [SocialSequenceNo sharedInstance];
    seqNo = seqObj.sequenceNo;
    [self getSWUserInfo:seqNo];
    return seqNo;
}

/**
 *  由于判断了登录，需要和登录的流程中一样的序列号
 *
 *  @param seqNo 序列号
 *
 *  @return 请求的序列号
 */
- (long)getSWUserInfo:(long)seqNo
{
    long tseqNo = [self getSWUserInfo:seqNo requestTag:nil processCmdId:-1 processSeqNo:-1];
    return tseqNo;
}

- (long)getSWUserInfo:(long)seqNo requestTag:(NSString *)requestTag processCmdId:(NSInteger)tpType processSeqNo:(long)pSeqNo
{
    if (seqNo <= 0)
    {
        return seqNo;
    }
    
    //如果请求的requestTag为空的话，默认使用kSinaWeiboGetUserInfoRequestTag
    if (!requestTag || requestTag.length <= 0)
    {
        requestTag = kSinaWeiboGetUserInfoRequestTag;
    }
    
    NSString *swUserId = _userID;
    if (!swUserId)
    {
        swUserId = @"";
    }
    //NSString *rtag = [self composeSWRequestTag:requestTag seqNo:seqNo];
    NSString *rtag = [self composeSWRequestTag:requestTag seqNo:seqNo processCmdId:tpType processSeqNo:pSeqNo];
    [WBHttpRequest requestWithAccessToken:_accessToken
                                      url:kSinaWeiboUserShowURL
                               httpMethod:@"GET"
                                   params:@{@"uid": swUserId}
                                 delegate:self
                                  withTag:rtag];
    return seqNo;
}

- (long)ssoLogin
{
    long seqNo = -1;
//    NSString *wbURL = [_configDict objectForKey:@"RedirectURL"];
//    if (!wbURL || wbURL.length <= 0)
//    {
//        return seqNo;
//    }
//    
//    SocialSequenceNo *seqObj = [SocialSequenceNo sharedInstance];
//    seqNo = seqObj.sequenceNo;
//    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
//    request.redirectURI = wbURL;
//    request.scope = @"all";
//    request.userInfo = @{KSinaWeiboRequestKey: kSinaWeiboSSOLoginRequestTag, KResponseSeqNo:[NSNumber numberWithLong:seqNo]};
//    [WeiboSDK sendRequest:request];
    
    seqNo = [self ssoLoginBy:kSinaWeiboSSOLoginRequestTag];
    return seqNo;
}

- (long)ssoLoginBy:(NSString *)requestKey
{
    long seqNo = -1;
    if (!requestKey || requestKey.length <= 0)
    {
        return seqNo;
    }
    
    NSString *wbURL = [_configDict objectForKey:@"RedirectURL"];
    if (!wbURL || wbURL.length <= 0)
    {
        return seqNo;
    }
    
    SocialSequenceNo *seqObj = [SocialSequenceNo sharedInstance];
    seqNo = seqObj.sequenceNo;
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = wbURL;
    request.scope = @"all";
    request.userInfo = @{KSinaWeiboRequestKey: requestKey, KResponseSeqNo:[NSNumber numberWithLong:seqNo]};
    BOOL flag = [WeiboSDK sendRequest:request];
    NSLog(@"sso login request status: %d", flag);
    return seqNo;
}

- (long)ssoLogout
{
    long seqNo = -1;
    BOOL flag = [self checkUserInfo];
    if (flag)
    {
        SocialSequenceNo *seqObj = [SocialSequenceNo sharedInstance];
        seqNo = seqObj.sequenceNo;
        NSString *rtag = [self composeSWRequestTag:kSinaWeiboSSOLogoutRequestTag seqNo:seqNo];
        [WeiboSDK logOutWithToken:_accessToken delegate:self withTag:rtag];
    }
    return seqNo;
}

#pragma mark -
#pragma mark --------分享-------------
- (NSInteger)shareContentWith:(SocialEntity *)content delegate:(id<SocialAPIDelegate>)delegate
{
    NSInteger seqNo = -1;
    _shareContent  = content;
    self.delegate = delegate;
    seqNo = [self shareSWContentWith:content];
    return seqNo;
}

- (NSInteger)shareContentAndLoginWith:(SocialEntity *)content delegate:(id<SocialAPIDelegate>)delegate
{
    NSInteger seqNo = -1;
    _shareContent  = content;
    BOOL flag = [self checkUserInfo];
    self.delegate = delegate;
    if (flag)
    {
        seqNo = [self shareSWContentWith:content];
    } else {
        seqNo = [self ssoLoginBy:kSinaWeiboShareSSOLoginRequestTag];
    }
    return seqNo;
}

- (long)shareSWContentWith:(SocialEntity *)shareContent
{
    long seqNo = -1;
    SocialSequenceNo *seqObj = [SocialSequenceNo sharedInstance];
    seqNo = seqObj.sequenceNo;
    seqNo = [self shareSWContentWith:shareContent seqNo:seqNo];
    
    return seqNo;
}

//- (long)shareSWContent:(NSDictionary *)shareDict
//{
//    long seqNo = -1;
//    SocialSequenceNo *seqObj = [SocialSequenceNo sharedInstance];
//    seqNo = seqObj.sequenceNo;
//    
//    [self shareSWContent:shareDict seqNo:seqNo];
//    
//    return seqNo;
//}

//- (NSInteger)shareSWContentWith:(SocialEntity *)shareContent seqNo:(long)seqNo
//{
//    if (seqNo <= 0)
//    {
//        return seqNo;
//    }
//    
//    NSString *rtag = [self composeSWRequestTag:kSinaWeiboShareRequestTag seqNo:seqNo];
//    NSString *requestURL = [shareDict.allKeys containsObject:@"pic"] ? kSinaWeiboImageShareURL : kSinaWeiboShareURL;
//    NSString *token = _accessToken;
//    DEBUGG(@"before shareSinaWeibo. url:%@ token:%@", requestURL, _accessToken);
//    [WBHttpRequest requestWithAccessToken:token
//                                      url:requestURL
//                               httpMethod:@"POST"
//                                   params:_shareParamDict
//                                 delegate:self
//                                  withTag:rtag];
//    return seqNo;
//}

- (NSInteger)shareSWContentWith:(SocialEntity *)shareContent seqNo:(NSInteger)seqNo
{
    if (seqNo <= 0)
    {
        return seqNo;
    }
    
    WBMessageObject *msg = [WBMessageObject message];
    WBWebpageObject *mediaObj = [WBWebpageObject object];
    mediaObj.objectID = shareContent.identifier;
    NSData *thumbImageData = nil;
    id image = shareContent.shareImage;
    NSURL *imageURL = shareContent.shareImageURL;
    if([image isKindOfClass:[NSData class]])
    {
        thumbImageData = image;
    }
    else if (imageURL)
    {
        thumbImageData = [NSData dataWithContentsOfURL:imageURL];
    }
    mediaObj.thumbnailData = thumbImageData;//
    mediaObj.title = shareContent.title;
    mediaObj.description = shareContent.shareText;
    mediaObj.scheme = shareContent.url;
    mediaObj.webpageUrl = shareContent.url;
    msg.mediaObject = mediaObj;
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:msg];
    
    if ([WeiboSDK sendRequest:request])
    {
        NSLog(@"微博发送消息成功");
    }
    return seqNo;
}

//- (long)shareSWContent:(NSDictionary *)shareDict seqNo:(long)seqNo
//{
//    if (seqNo <= 0)
//    {
//        return seqNo;
//    }
//    
//    NSString *rtag = [self composeSWRequestTag:kSinaWeiboShareRequestTag seqNo:seqNo];
//    NSString *requestURL = [shareDict.allKeys containsObject:@"pic"] ? kSinaWeiboImageShareURL : kSinaWeiboShareURL;
//    DEBUGG(@"before shareSinaWeibo. url:%@ token:%@", requestURL, _accessToken);
//    [WBHttpRequest requestWithAccessToken:_accessToken
//                                      url:requestURL
//                               httpMethod:@"POST"
//                                   params:_shareParamDict
//                                 delegate:self
//                                  withTag:rtag];
//    return seqNo;
//}

#pragma mark - WeiboSDKDelegate
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    DEBUGG(@"%@ didReceiveWeiboRequest(), request: %@", self, request);
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if (response.statusCode == WeiboSDKResponseStatusCodeSuccess)
    {
        // 成功
        NSDictionary *userInfo = response.requestUserInfo;
        if ([response isKindOfClass:[WBAuthorizeResponse class]])
        {
            // 登录返回
            WBAuthorizeResponse *authorizeRespose = (WBAuthorizeResponse *)response;
            //赋值新浪微博的用户数据
            NSString *swUserId = authorizeRespose.userID;
            if (!swUserId)
            {
                swUserId = @"";
            }
            NSString *swAccessToken = authorizeRespose.accessToken;
            if (!swAccessToken)
            {
                swAccessToken = @"";
            }
            _userID = swUserId;
            _accessToken = swAccessToken;
            _expirationDate = authorizeRespose.expirationDate;
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            if (_accessToken)
            {
                [dict setObject:_accessToken forKey:KSinaWeiboAccessToken];
            }
            if (_userID)
            {
                [dict setObject:_userID forKey:KSinaWeiboUserId];
            }
            if (_expirationDate)
            {
                [dict setObject:_expirationDate forKey:KSinaWeiboExpirationDate];
            }
            //判断用户信息是否完整
            if (dict.count >= 3)
            {
                //存储新浪微博的用户数据
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];;
                [userDefaults setObject:dict forKey:KSinaWeiboUserInfo];
                [userDefaults synchronize];
            }
            
            NSString *requestKey = [userInfo objectForKey:KSinaWeiboRequestKey];
            NSNumber *seqNum = [userInfo objectForKey:KResponseSeqNo];
            long seqNo = seqNum.longValue;
            if ([kSinaWeiboSSOLoginRequestTag isEqualToString:requestKey])
            {
                /**
                 *  Semny,2015-05-06,组合结果包并发送请求
                 */
                NSDictionary *bodyDict = @{KSinaWeiboAccessToken: swAccessToken, KSinaWeiboUserId: swUserId};
                NSInteger cmdId = SSO_CMD_SinaWeiboSSOToken;
                NSInteger pcmdId = SSO_CMD_SinaWeiboLoginProcess;
                NSInteger pseqno = seqNo;
                [self composeSWNormalResultBy:cmdId seqNo:seqNo body:bodyDict processCmdId:pcmdId processSeqNo:pseqno];
            }
            else if ([kSinaWeiboShareSSOLoginRequestTag isEqualToString:requestKey])
            {
                //分享之前由于无效的token或用户信息，需要先登录，然后分享，而且得保持两个操作的seqNo一致
                //[self shareSWContent:_shareParamDict seqNo:seqNo];
            }
            else if ([kSinaWeiboGetUserSSOLoginRequestTag isEqualToString:requestKey])
            {
                //获取新浪微博用户信息之前由于无效的token或用户信息，需要先登录，然后获取，而且得保持两个操作的seqNo一致
                [self getSWUserInfo:seqNo];
            }
        }
        else if ([response isKindOfClass:[WBSendMessageToWeiboResponse class]])
        {
            /*WBSendMessageToWeiboResponse *messageRespose = (WBSendMessageToWeiboResponse *)response;
            if ([userInfo[KSinaWeiboRequestKey] isEqualToString:kSinaWeiboShareRequestTag]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"分享成功" delegate: self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }
             */
        }
    }
    else
    {
        //失败
        NSDictionary *userInfo = response.requestUserInfo;
        if ([response isKindOfClass:[WBAuthorizeResponse class]])
        {
            // 登录返回
            NSString *requestKey = [userInfo objectForKey:KSinaWeiboRequestKey];
            /**
             *  Semny,2015-05-06,组合结果包并发送请求
             */
            NSNumber *seqNum = [userInfo objectForKey:KResponseSeqNo];
            long seqNo = seqNum.longValue;
            
            NSInteger cmdId = -1;
            NSInteger pcmdId = -1;
            NSInteger pseqno = -1;
            if ([kSinaWeiboSSOLoginRequestTag isEqualToString:requestKey])
            {
                cmdId = SSO_CMD_SinaWeiboSSOToken;
                pcmdId = SSO_CMD_SinaWeiboLoginProcess;
                pseqno = seqNo;
            }
            else if ([kSinaWeiboShareSSOLoginRequestTag isEqualToString:requestKey])
            {
                cmdId = SSO_CMD_SinaWeiboShareLogin;
            }
            else if ([kSinaWeiboGetUserSSOLoginRequestTag isEqualToString:requestKey])
            {
                cmdId = SSO_CMD_SinaWeiboGetUserLogin;
            }
            
            [self composeSWErrorResultAndPostBy:cmdId seqNo:seqNo processCmdId:pcmdId processSeqNo:pseqno];
            //[self composeSWErrorResultAndPostBy:cmdId seqNo:seqNo];
        }
        else if ([response isKindOfClass:[WBSendMessageToWeiboResponse class]])
        {
        }
        //请求错误的情况
        DEBUGG(@"%@ didReceiveWeiboResponse(), response: %@", self, response);
    }
}

#pragma mark - WBHttpRequestDelegate
- (void)request:(WBHttpRequest *)request didFinishLoadingWithResult:(NSString *)result
{
    NSString *composeTag = request.tag;
    NSString *tag = [self getNormalRequestTagFrom:composeTag];
    long seqNo = [self getSeqNoFrom:composeTag];
    DEBUGG(@"%s <<<>>> tag: %@ <<<>>> WBHttpRequest result: %@", __FUNCTION__, tag, result);
    if ([tag isEqualToString:kSinaWeiboSSOLogoutRequestTag])
    {
        //清理登录用户信息
        [self clearSinaWeiboUserInfo:YES];
    }
    else if ([tag isEqualToString:kSinaWeiboShareRequestTag])
    {
        //微博创建的时间
        NSString *createdTime = nil;
        if (result)
        {
            NSError *error = nil;
            NSData *resultData = [result dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:&error];
            if (resultDict && resultDict.count > 0)
            {
                createdTime = [resultDict objectForKey:@"created_at"];
            }
        }
        
        DEBUGG(@"%s After shareSinaWeibo. url:%@ token:%@ returnData:%@",__FUNCTION__, request.url, _accessToken, result);
        //新浪微博分享完成
        //NSRange range = [result rangeOfString:@"created_at"];
        if (createdTime && createdTime.length > 0)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:KNoticeTitle message:KShareSuccessTitle delegate: self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            
            // 通知服务器，文章已经分享成功
            //未安装时无法走安装客户端的逻辑因此放到这里
            if (![self isWeiboInstalled]) {
                //通知服务端分享操作
            }
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:KNoticeTitle message:KShareFailedTitle delegate: self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            //通知分享失败
            
        }
        
        //发送新浪微博分享的通知
        //[[NSNotificationCenter defaultCenter] postNotificationName:SSOObtainSinaWeiboShareNotification object:nil];
        
        NSInteger cmdId = SSO_CMD_SinaWeiboShare;
        NSInteger pcmdId = SSO_CMD_SinaWeiboShareProcess;
        NSInteger pseqno = seqNo;
        [self composeSWNormalResultBy:cmdId seqNo:seqNo body:nil processCmdId:pcmdId processSeqNo:pseqno];
    }
    else if ([tag isEqualToString:kSinaWeiboGetUserInfoRequestTag])
    {
        DEBUGG(@"===%@", result);
        
        NSInteger pCmdId = [self getPCmdIdFrom:composeTag];
        long pSeqNo = [self getPSeqNoFrom:composeTag];
        
        NSData *resultData = [result dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
        //解析数据
        //TODO: sina parser data
        NSLog(@"sina user info request result: %@", resultDict);
        
        id result = nil;
        
        NSInteger cmdId = SSO_CMD_SinaWeiboUserInfo;
        [self composeSWNormalResultBy:cmdId seqNo:seqNo body:result processCmdId:pCmdId processSeqNo:pSeqNo];
    }
}

- (void)request:(WBHttpRequest *)request didFailWithError:(NSError *)error
{
    //新浪微博的错误处理
    NSString *composeTag = request.tag;
    NSString *tag = [self getNormalRequestTagFrom:composeTag];
    long seqNo = [self getSeqNoFrom:composeTag];
    if ([tag isEqualToString:kSinaWeiboSSOLogoutRequestTag])
    {
    }
    else if ([tag isEqualToString:kSinaWeiboShareRequestTag])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:KNoticeTitle message:KShareFailedTitle delegate: self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    else if ([tag isEqualToString:kSinaWeiboGetUserInfoRequestTag])
    {
        NSInteger pCmdId = [self getPCmdIdFrom:composeTag];
        long pSeqNo = [self getPSeqNoFrom:composeTag];
        
        //发送获取新浪用户信息的通知
        NSInteger cmdId = SSO_CMD_SinaWeiboUserInfo;
        [self composeSWErrorResultAndPostBy:cmdId seqNo:seqNo processCmdId:pCmdId processSeqNo:pSeqNo];
    }
    DEBUGG(@"%@ request:didFailWithError tag: %@!",self, tag);
}

/**
 *  清理信息
 */
- (void)clearUserInfo
{
    [self clearSinaWeiboUserInfo:NO];
}

#pragma mark -
#pragma mark -------------包组合---------------
/**
 *  新浪微博错误组合包
 */
- (void)composeSWErrorResultAndPostBy:(NSInteger)cmdId seqNo:(NSInteger)seqNo processCmdId:(NSInteger)tpType processSeqNo:(long)pSeqNo
{
    [self composeSWResultBy:cmdId seqNo:seqNo body:nil processCmdId:tpType processSeqNo:pSeqNo flag:NO];
}

/**
 *  新浪微博正常组合包
 */
- (void)composeSWNormalResultBy:(NSInteger)cmdId seqNo:(NSInteger)seqNo body:(id)body  processCmdId:(NSInteger)tpType processSeqNo:(long)pSeqNo
{
    [self composeSWResultBy:cmdId seqNo:seqNo body:body processCmdId:tpType processSeqNo:pSeqNo flag:YES];
}

/**
 *  组合请求的返回结果包体
 *
 *  @param cmdId     当前请求的类型
 *  @param seqNo     当前请求的序列号
 *  @param body      请求结果包体
 *  @param tpType    请求的流程类型，也就是processCmdId
 *  @param pSeqNo    请求的流程序列号
 *  @param isSuccess 是否成功
 */
- (void)composeSWResultBy:(NSInteger)cmdId seqNo:(NSInteger)seqNo body:(id)body processCmdId:(NSInteger)tpType processSeqNo:(long)pSeqNo flag:(BOOL)isSuccess
{
//    if (cmdId < 0 || seqNo <= 0)
//    {
//        return;
//    }
//    
//    int requestStatus = SSO_REQUEST_CODE_ERROR;
//    int resultCode = SSO_RES_UNKNOWN;
//    if (isSuccess)
//    {
//        requestStatus = SSO_REQUEST_CODE_SUCCESS;
//        resultCode = SSO_RES_SUCCESS;
//    }
//    NSMutableDictionary *mResult = nil;
//    mResult = [NSMutableDictionary dictionary];
//    
//    NSDictionary *header = @{KResponseSeqNo:[NSNumber numberWithInteger:seqNo], KTCPResponseCmdId:[NSNumber numberWithInteger:cmdId], KTCPResponseResult:[NSNumber numberWithInteger:resultCode]};
//    [mResult setObject:header forKey:KResponseHeader];
//    if (tpType >= 0 && pSeqNo > 0)
//    {
//        [mResult setObject:[NSNumber numberWithInteger:tpType] forKey:KTCPRequestProcessCmdId];
//        [mResult setObject:[NSNumber numberWithLong:pSeqNo] forKey:KTCPRequestProcessSeqNo];
//    }
//    
//    NSDictionary *result = nil;
//    if (body)
//    {
//        [mResult setObject:body forKey:KResponseBody];
//        result = @{KTCPResponseLCode:[NSNumber numberWithInt:requestStatus], KTCPResponseLResult:mResult};
//    }
//    else
//    {
//        result = @{KTCPResponseLCode:[NSNumber numberWithInt:requestStatus], KTCPResponseLResult:mResult};
//    }
//    
//    NSString *notifyName = [MEResultUtils getResultNotifyNameBy:cmdId];
//    if (notifyName && notifyName.length > 0)
//    {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [[NSNotificationCenter defaultCenter] postNotificationName:notifyName object:result];
//        });
//    }
}

/**
 *  组合新浪微博接口的请求tag
 *
 *  @param requestType 基本的tag类型字符串
 *  @param seqNo       请求序列号
 *
 *  @return 组合好的tag标签
 */
- (NSString *)composeSWRequestTag:(NSString *)requestType seqNo:(long)seqNo
{
    NSMutableString *rtag = nil;
    if (!requestType || requestType.length <= 0)
    {
        return rtag;
    }
    
    rtag = [NSMutableString stringWithString:requestType];
    if (seqNo > 0)
    {
        [rtag appendFormat:@"_%ld", seqNo];
    }
    return rtag;
}

- (NSString *)composeSWRequestTag:(NSString *)requestType seqNo:(long)seqNo processCmdId:(NSInteger)pCmdId processSeqNo:(long)pSeqNo
{
    NSMutableString *rtag = nil;
    if (!requestType || requestType.length <= 0)
    {
        return rtag;
    }
    
    rtag = [NSMutableString stringWithString:requestType];
    if (seqNo > 0)
    {
        [rtag appendFormat:@"_%ld", seqNo];
    }
    
    if (pCmdId >= 0 && pSeqNo > 0)
    {
        [rtag appendFormat:@"_%d_%ld", (int)pCmdId, pSeqNo];
    }
    return rtag;
}

/**
 *  获取接口的基础分类标签
 *
 *  @param composeSWRequestTag 组合标签
 *
 *  @return 接口的基础分类标签
 */
- (NSString *)getNormalRequestTagFrom:(NSString *)composeSWRequestTag
{
    NSString *nTag = nil;
    if (!composeSWRequestTag || composeSWRequestTag.length <= 0)
    {
        return nTag;
    }
    NSArray *subStrs = [composeSWRequestTag componentsSeparatedByString:@"_"];
    if (subStrs.count > 0)
    {
        nTag = [subStrs objectAtIndex:0];
    }
    return nTag;
}

/**
 *  根据组合标签获取序列号
 *
 *  @param composeSWRequestTag 组合标签
 *
 *  @return 序列号
 */
- (long)getSeqNoFrom:(NSString *)composeSWRequestTag
{
    long seqNo = -1;
    if (!composeSWRequestTag || composeSWRequestTag.length <= 0)
    {
        return seqNo;
    }
    NSArray *subStrs = [composeSWRequestTag componentsSeparatedByString:@"_"];
    if (subStrs.count > 1)
    {
        NSString *seqNoStr = [subStrs objectAtIndex:1];
        if (seqNoStr)
        {
            seqNo = [seqNoStr integerValue];
        }
    }
    return seqNo;
}

- (long)getPSeqNoFrom:(NSString *)composeSWRequestTag
{
    long seqNo = -1;
    if (!composeSWRequestTag || composeSWRequestTag.length <= 0)
    {
        return seqNo;
    }
    NSArray *subStrs = [composeSWRequestTag componentsSeparatedByString:@"_"];
    if (subStrs.count > 2)
    {
        NSString *seqNoStr = [subStrs objectAtIndex:2];
        if (seqNoStr)
        {
            seqNo = [seqNoStr integerValue];
        }
    }
    return seqNo;
}

- (NSInteger)getPCmdIdFrom:(NSString *)composeSWRequestTag
{
    NSInteger pCmdId = -1;
    if (!composeSWRequestTag || composeSWRequestTag.length <= 0)
    {
        return pCmdId;
    }
    NSArray *subStrs = [composeSWRequestTag componentsSeparatedByString:@"_"];
    if (subStrs.count > 3)
    {
        NSString *pCmdIdStr = [subStrs objectAtIndex:3];
        if (pCmdIdStr)
        {
            pCmdId = [pCmdIdStr integerValue];
        }
    }
    return pCmdId;
}
@end
