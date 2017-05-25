//
//  TencentQQ.m
//  
//
//  Created by Semny on 14-9-25.
//  Copyright (c) 2014年 Semny. All rights reserved.
//

#import "SocialAPITencentQQ.h"
#import "SocialSequenceNo.h"

// 社交分享的目标平台
typedef enum : NSUInteger {
    SocialAPITencentQQTypeQQZone=1,            //QQ空间
    SocialAPITencentQQTypeQQ,                //QQ好友
} SocialAPITencentQQType;

@interface SocialAPITencentQQ () <TencentSessionDelegate>
{
    NSDictionary *_configDic;
    QQApiNewsObject *_newsObj;
}

@end

@implementation SocialAPITencentQQ

- (instancetype)init
{
    self = [super init];
    if (self) {
        _configDic = self.platformsConfigDic[@"QQ"];
    }
    return self;
}

- (void)registerApp {
    _tencentOAuth = [[TencentOAuth alloc] initWithAppId:_configDic[@"AppID"] andDelegate:self];
//    _tencentOAuth.redirectURI = @"www.qq.com";
}

- (BOOL)isQQInstalled {
    return [TencentOAuth iphoneQQInstalled];
}

- (long)ssoLogin
{
    long seqNo = -1;
    // 权限列表
    NSArray *permissions = [NSArray arrayWithObjects:
                            kOPEN_PERMISSION_GET_INFO,
                            kOPEN_PERMISSION_GET_USER_INFO,
                            kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                            kOPEN_PERMISSION_ADD_TOPIC,
                            kOPEN_PERMISSION_ADD_SHARE, nil];
    [_tencentOAuth authorize:permissions];
    
    SocialSequenceNo *seqObj = [SocialSequenceNo sharedInstance];
    seqNo = seqObj.sequenceNo;
    
    return seqNo;
}

- (long)ssoLogout
{
    long seqNo = -1;
    [_tencentOAuth logout:_sessionDelegate];
    
    SocialSequenceNo *seqObj = [SocialSequenceNo sharedInstance];
    seqNo = seqObj.sequenceNo;
    
    return seqNo;
}

- (long)getUserInfo
{
    long seqNo = -1;
    
    SocialSequenceNo *seqObj = [SocialSequenceNo sharedInstance];
    seqNo = seqObj.sequenceNo;
    if (![_tencentOAuth getUserInfo])
    {
        NSLog(@"TencentOAuth API调用失败！");
    }
    return seqNo;
}

//- (long)shareContent:(NSMutableDictionary *)contentDic
//{
//    long seqNo = -1;
//    _newsObj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:contentDic[@"URL"]]
//                                        title:contentDic[@"Title"]
//                                  description:contentDic[@"Summary"]
//                              previewImageURL:[NSURL URLWithString:contentDic[@"ImagesURL"]]];
//    
//    
//    if ([_tencentOAuth isSessionValid])
//    {
//        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:_newsObj];
//        NSInteger ret = [QQApiInterface SendReqToQZone:req];
//
//        if (ret != EQQAPISENDSUCESS)
//        {
//            NSLog(@"分享到Qzone失败！");
//        }
//    } else {
//        [self ssoLogin];
//    }
//    SocialSequenceNo *seqObj = [SocialSequenceNo sharedInstance];
//    seqNo = seqObj.sequenceNo;
//    return seqNo;
//}

/**
 *  @author semny
 *
 *  分享到QQ好友
 *
 *  @param content 分享内容
 *
 *  @return 序列号
 */
- (NSInteger)shareContentWith:(SocialEntity *)content
{
    NSInteger seqNo = [self shareContentToQQWith:content delegate:self.delegate];
    return seqNo;
}

/**
 *  @author semny
 *
 *  分享到QQ空间
 *
 *  @param content 分享内容
 *
 *  @return 序列号
 */
- (NSInteger)shareContentToQQWith:(SocialEntity *)content delegate:(id<SocialAPIDelegate>)delegate
{
    NSInteger seqNo = [self shareOnlyContentWith:content type:SocialAPITencentQQTypeQQ delegate:self.delegate];
    return seqNo;
}

/**
 *  @author semny
 *
 *  分享到QQ空间
 *
 *  @param content 分享内容
 *
 *  @return 序列号
 */
- (NSInteger)shareContentToQZoneWith:(SocialEntity *)content
{
    NSInteger seqNo = [self shareContentToQZoneWith:content delegate:self.delegate];
    return seqNo;
}

- (NSInteger)shareContentToQZoneWith:(SocialEntity *)content delegate:(id<SocialAPIDelegate>)delegate
{
    return [self shareOnlyContentWith:content type:SocialAPITencentQQTypeQQZone delegate:delegate];
}

- (NSInteger)shareOnlyContentWith:(SocialEntity *)content type:(SocialAPITencentQQType)type delegate:(id<SocialAPIDelegate>)delegate
{
    NSInteger seqNo = -1;
    //分享的url
    NSString *shareURLStr = content.url;
    NSURL *shareURL = nil;
    if (shareURLStr && shareURLStr.length > 0)
    {
        shareURL = [NSURL URLWithString:shareURLStr];
    }
    //分享的url
    NSString *title = content.title;
    //分享的描述
    NSString *shareText = content.shareText;
    //分享的预览图url
    NSURL *previewImageURL = content.shareImageURL;
    _newsObj = [QQApiNewsObject objectWithURL:shareURL
                                        title:title
                                  description:shareText
                              previewImageURL:previewImageURL];
    
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:_newsObj];
    //代理
    self.delegate = delegate;
    
    BOOL flag = YES;
    NSInteger snsType = -1;
    if (type == SocialAPITencentQQTypeQQ)
    {
        snsType = SocialAPISNSTypeQQ;
        //QQ分享
        NSInteger ret = [QQApiInterface sendReq:req];
        if (ret != EQQAPISENDSUCESS)
        {
            NSLog(@"分享到Qzone失败！");
            flag = NO;
        }
    }
    else if(type == SocialAPITencentQQTypeQQZone)
    {
        snsType = SocialAPISNSTypeQQZone;
        //QQ空间
        NSInteger ret = [QQApiInterface SendReqToQZone:req];
        if (ret != EQQAPISENDSUCESS)
        {
            NSLog(@"分享到Qzone失败！");
            flag = NO;
        }
    }
    if(!flag || snsType<0)
    {
        //分享错误
        NSInteger errorCode = SSO_API_RESULT_SHARE_ERROR;
        NSDictionary *errorinfo = nil;
        NSError *error = [NSError errorWithDomain:KSocialAPIResultErrorDomain code:errorCode userInfo:errorinfo];
        
        //错误代理
        if (self.delegate && [self.delegate respondsToSelector:@selector(didFailedSocialAPIType:error:)])
        {
            [self.delegate didFailedSocialAPIType:snsType error:error];
        }
    }
    SocialSequenceNo *seqObj = [SocialSequenceNo sharedInstance];
    seqNo = seqObj.sequenceNo;
    return seqNo;
}

///**
// *  @author semny
// *
// *  分享并且判断是否登录态有效，登录
// *
// *  @param content 分享实体
// *  @param type    分享类型
// *
// *  @return 请求序列号
// */
//- (NSInteger)shareContentWith:(SocialEntity *)content type:(SocialAPITencentQQType)type
//{
//    NSInteger seqNo = -1;
//    //分享的url
//    NSString *shareURLStr = content.url;
//    NSURL *shareURL = nil;
//    if (shareURLStr && shareURLStr.length > 0)
//    {
//        shareURL = [NSURL URLWithString:shareURLStr];
//    }
//    //分享的url
//    NSString *title = content.title;
//    //分享的描述
//    NSString *shareText = content.shareText;
//    //分享的预览图url
//    NSString *previewImageURLStr = nil;
//    NSURL *previewImageURL = nil;
//    if (previewImageURLStr && previewImageURLStr.length > 0)
//    {
//        previewImageURL = [NSURL URLWithString:previewImageURLStr];
//    }
//    _newsObj = [QQApiNewsObject objectWithURL:shareURL
//                                        title:title
//                                  description:shareText
//                              previewImageURL:previewImageURL];
//    
//    //判断是否登录有效
//    if ([_tencentOAuth isSessionValid])
//    {
//        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:_newsObj];
//        
//        if (type == SocialAPITencentQQTypeQQ)
//        {
//            //QQ分享
//            NSInteger ret = [QQApiInterface sendReq:req];
//            if (ret != EQQAPISENDSUCESS)
//            {
//                NSLog(@"分享到Qzone失败！");
//            }
//        }
//        else if(type == SocialAPITencentQQTypeQQZone)
//        {
//            //QQ空间
//            NSInteger ret = [QQApiInterface SendReqToQZone:req];
//            if (ret != EQQAPISENDSUCESS)
//            {
//                NSLog(@"分享到Qzone失败！");
//            }
//        }
//    }
//    else
//    {
//        [self ssoLogin];
//    }
//    SocialSequenceNo *seqObj = [SocialSequenceNo sharedInstance];
//    seqNo = seqObj.sequenceNo;
//    return seqNo;
//}

#pragma mark - TencentSessionDelegate

- (void)tencentDidLogin {
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:_newsObj];
    if ([QQApiInterface SendReqToQZone:req] != EQQAPISENDSUCESS) {
        NSLog(@"分享到Qzone失败！");
    }
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{
    
}

-(void)tencentDidNotNetWork
{
    
}

#pragma mark - QQApiInterfaceDelegate

- (void)onReq:(QQBaseReq *)req {
    NSLog(@"QQ req:%@", req);
}

- (void)onResp:(QQBaseResp *)resp {
    if ([resp isKindOfClass:[SendMessageToQQResp class]]) {
        SendMessageToQQResp *response = (SendMessageToQQResp *)resp;
        NSLog(@"QQ resp code:%@ descrep:%@", response.result, response.errorDescription);
        if ([response.result isEqualToString:@"0"]) {
//            while ([METCPRequest sharedTCPRequest].isConnectSuccess == NO) {
//                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
//            }

//TODO: qq response
            if (![self isQQInstalled]) {
            //通知服务端分享操作
            }
        }
    }
}

-(void)isOnlineResponse:(NSDictionary *)response {
    NSLog(@"QQ isOnlineResponse:%@", response);
}
@end
