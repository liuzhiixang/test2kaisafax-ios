//
//  SocialAPIWeChat.m
//  
//
//  Created by Semny on 14-9-23.
//  Copyright (c) 2014年 Semny. All rights reserved.
//

#import "SocialAPIWeChat.h"
#import "SocialSequenceNo.h"

@interface SocialAPIWeChat () <SocialAPIWeChatHttpRequestDelegate> {
    NSDictionary *_configDic;
}


@end

@implementation SocialAPIWeChat

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _configDic = self.platformsConfigDic[@"WeChat"];
    }
    return self;
}

- (instancetype)initWithHTTPDelegate:(id<SocialAPIWeChatHttpRequestDelegate>)delegate
{
    self = [self init];
    if (self)
    {
        _httpDelegate = delegate;
    }
    return self;
}

- (void)registerApp {
    if ([WXApi registerApp:_configDic[@"AppID"]] == NO) {
        NSLog(@"===微信注册失败===");
    };
}

- (BOOL)isWeChatInstalled {
    return [WXApi isWXAppInstalled];
}

- (long)ssoLogin
{
    long seqNo = -1;
    
    //构造SendAuthReq结构体
    SendAuthReq *req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_userinfo,snsapi_base";
    req.state = @"WeChatSSOLogin";
    //第三方向微信终端发送一个SendAuthReq消息结构
    [WXApi sendReq:req];
    
    SocialSequenceNo *seqObj = [SocialSequenceNo sharedInstance];
    seqNo = seqObj.sequenceNo;
    
    return seqNo;
}

- (void)getAccessToken {
    if (_code != nil) {
        NSDictionary *params = @{@"appid": _configDic[@"AppID"],
                                 @"secret": _configDic[@"AppSecret"],
                                 @"code": _code,
                                 @"grant_type": @"authorization_code"};
        
        WXHTTPRequest *wxHTTPRequest = [[WXHTTPRequest alloc] init];
        [wxHTTPRequest requestWithWXURL:@"https://api.weixin.qq.com/sns/oauth2/access_token"
                             httpMethod:@"GET"
                                 params:params
                               delegate:_httpDelegate
                                withTag:@"WeChatGetAccessToken"];
    }
}

- (long)getUserInfo
{
    long seqNo = -1;
    
    if (_accessToken != nil) {
        NSDictionary *params = @{@"access_token": _accessToken,
                                 @"openid": _openID};
        
        WXHTTPRequest *wxHTTPRequest = [[WXHTTPRequest alloc] init];
        [wxHTTPRequest requestWithWXURL:@"https://api.weixin.qq.com/sns/userinfo"
                             httpMethod:@"GET"
                                 params:params
                               delegate:_httpDelegate
                                withTag:@"WeChatGetUserInfo"];
    }
    
    SocialSequenceNo *seqObj = [SocialSequenceNo sharedInstance];
    seqNo = seqObj.sequenceNo;
    
    return seqNo;
}

- (long)ssoLogout
{
    // 未能实现
    long seqNo = -1;
    return seqNo;
}

//默认是微信好友
- (NSInteger)shareContentWith:(SocialEntity *)content
{
    return [self shareContentWith:content delegate:nil];
}

//默认是微信好友
- (NSInteger)shareContentWith:(SocialEntity *)content delegate:(id<SocialAPIDelegate>)delegate
{
    NSInteger seqNo = [self shareContentWith:content type:WXSceneSession delegate:delegate];
    return seqNo;
}

/**
 *  @author semny
 *
 *  朋友圈分享
 *
 *  @param content 分享内容
 *
 *  @return 序列号
 */
- (NSInteger)shareContentToTimelineWith:(SocialEntity *)content
{
    return [self shareContentToTimelineWith:content delegate:self.delegate];
}

/**
 *  @author semny
 *
 *  朋友圈分享
 *
 *  @param content 分享内容
 *
 *  @return 序列号
 */
- (NSInteger)shareContentToTimelineWith:(SocialEntity *)content delegate:(id<SocialAPIDelegate>)delegate
{
    NSInteger seqNo = [self shareContentWith:content type:WXSceneTimeline delegate:delegate];
    return seqNo;
}

- (NSInteger)shareContentWith:(SocialEntity *)content type:(enum WXScene)scene delegate:(id<SocialAPIDelegate>)delegate
{
    NSInteger seqNo = -1;
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = content.title;
    message.description = content.shareText;
    id image = content.shareImage;
    UIImage *thumbImage = nil;
    if([image isKindOfClass:[NSData class]])
    {
        thumbImage = [UIImage imageWithData:image];
    }
    else if ([image isKindOfClass:[UIImage class]])
    {
        thumbImage = image;
    }
    [message setThumbImage:thumbImage];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = content.url;
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.type = WeChatSendLinkRequest;
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    
    //分享请求
    BOOL flag = [WXApi sendReq:req];
    self.delegate = delegate;
    
    NSInteger snsType = -1;
    if (scene == WXSceneSession)
    {
        /**< 聊天界面    */
        //微信好友
        snsType = SocialAPISNSTypeWeChat;
    }
    else if(scene == WXSceneTimeline)
    {
        /**< 朋友圈      */
        snsType = SocialAPISNSTypeWeChatMoments;
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

- (void)shareContent:(NSMutableDictionary *)contentDic toScene:(enum WXScene)scene {
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = contentDic[@"Title"];
    message.description = contentDic[@"Description"];
    [message setThumbImage:contentDic[@"Image"]];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = contentDic[@"URL"];
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.type = WeChatSendLinkRequest;
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    
    [WXApi sendReq:req];
}

#pragma mark - WXApiDelegate

-(void) onReq:(BaseReq*)req {
    NSLog(@"wechat req:%@", req);
}

-(void) onResp:(BaseResp*)resp {
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        SendMessageToWXResp *response = (SendMessageToWXResp *)resp;
        if (response.errCode == 0) {
            /**
             *  Semny, 2015-03-14, 替换网络连接状态的检测
             */
//            while ([METCPRequest sharedTCPRequest].isConnectSuccess == NO) {
//                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
//            }
        }
    }
}

@end

