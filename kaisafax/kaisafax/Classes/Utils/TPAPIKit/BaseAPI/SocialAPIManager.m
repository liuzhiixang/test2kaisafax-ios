//
//  SocialAPIManager.m
//  
//
//  Created by Semny on 14-9-19.
//  Copyright (c) 2014年 Semny. All rights reserved.
//

#import "SocialAPIManager.h"

@interface SocialAPIManager ()<SocialAPIDelegate>
{
//    id appDelegate;
}

@property (strong, nonatomic) SocialAPISinaWeibo  *sinaWeibo;
@property (strong, nonatomic) SocialAPIWeChat     *weChat;
@property (strong, nonatomic) SocialAPITencentQQ  *tencentQQ;

//@property (weak, nonatomic) id<SocialAPIDelegate> snsDelegate;

@end

@implementation SocialAPIManager

+ (instancetype)sharedInstance
{
    static SocialAPIManager *obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[SocialAPIManager alloc] init];
    });
    
    return obj;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
//        appDelegate = [[UIApplication sharedApplication] delegate];
//        _tencentWeibo = [[SocialAPITencentWeibo alloc] initWithHTTPDelegate:appDelegate];
    }
    return self;
}

- (void)registerAppWithPlatforms:(NSArray *)platforms {
    for (NSString *platform in platforms) {
        if ([platform isEqualToString:@"WeChat"])
        {
            if (_weChat == nil) {
                _weChat = [[SocialAPIWeChat alloc] init];
                _weChat.delegate = self;
            }
            [_weChat registerApp];
        }
        else if ([platform isEqualToString:@"QQ"])
        {
            if (_tencentQQ == nil) {
                _tencentQQ = [[SocialAPITencentQQ alloc] init];
                _tencentQQ.delegate = self;
            }
            [_tencentQQ registerApp];
        }
        else if ([platform isEqualToString:@"SinaWeibo"])
        {
            if (_sinaWeibo == nil)
            {
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                NSDictionary *userInfo = [userDefaults objectForKey:KSinaWeiboUserInfo];
                _sinaWeibo = [[SocialAPISinaWeibo alloc] initWith:userInfo];
                //[[SocialAPISinaWeibo alloc] initWithHTTPDelegate:nil];
                _sinaWeibo.delegate = self;
            }
            _sinaWeibo.enableDebugMode = YES;
            [_sinaWeibo registerApp];
        }
    }
}

- (BOOL)isSSOClientInstalled:(SocialAPISSOType)client
{
    BOOL isInstalled = false;
    if (client == SocialAPISSOTypeWeChat)
    {
        isInstalled = [_weChat isWeChatInstalled];
    }
    else if (client == SocialAPISSOTypeQQ) {
        isInstalled = [_tencentQQ isQQInstalled];
    }
    else if (client == SocialAPISSOTypeSinaWeibo) {
        isInstalled = [_sinaWeibo isWeiboInstalled];
    }
    
    return isInstalled;
}

- (long)ssoLoginByType:(SocialAPISSOType)loginType
{
    long seqNo = -1;
    if (loginType == SocialAPISSOTypeWeChat) {
        [_weChat ssoLogin];
    }
    else if (loginType == SocialAPISSOTypeQQ) {
        [_tencentQQ ssoLogin];
    }
    else if (loginType == SocialAPISSOTypeSinaWeibo) {
        seqNo = [_sinaWeibo ssoLogin];
    }
    return seqNo;
}

- (long)getUserInfoByType:(SocialAPISSOType)type
{
    long seqNo = -1;
    if (type == SocialAPISSOTypeWeChat) {
        [_weChat getUserInfo];
    }
    else if (type == SocialAPISSOTypeQQ) {
        [_tencentQQ getUserInfo];
    }
    else if (type == SocialAPISSOTypeSinaWeibo) {
        seqNo = [_sinaWeibo getUserInfo];
    }
    return seqNo;
}

- (long)getUserInfoByType:(SocialAPISSOType)type processCmdId:(NSInteger)pCmdId processSeqNo:(long)pSeqNo
{
    long seqNo = -1;
    SocialAPIBasePlatform *tpObj = nil;
    if (type == SocialAPISSOTypeWeChat)
    {
        tpObj = _weChat;
    }
    else if (type == SocialAPISSOTypeQQ)
    {
        tpObj = _tencentQQ;
    }
    else if (type == SocialAPISSOTypeSinaWeibo)
    {
        tpObj = _sinaWeibo;
    }
    seqNo = [tpObj getUserInfo:pCmdId processSeqNo:pSeqNo];
    return seqNo;
}

- (long)ssoLogoutByType:(SocialAPISSOType)logoutType
{
    long seqNo = -1;
    if (logoutType == SocialAPISSOTypeWeChat) {
        
    }
    else if (logoutType == SocialAPISSOTypeQQ) {
        [_tencentQQ ssoLogout];
    }
    else if (logoutType == SocialAPISSOTypeSinaWeibo) {
        seqNo = [_sinaWeibo ssoLogout];
    }
    return seqNo;
}

- (void)shareContent:(SocialEntity *)content toPlatform:(SocialAPISNSType)platform
{
    switch (platform)
    {
        case SocialAPISNSTypeWeChat:
        {
            //微信好友
            [_weChat shareContentWith:content];
        }
            break;
        case SocialAPISNSTypeWeChatMoments:
        {
            //朋友圈
            [_weChat shareContentToTimelineWith:content];
        }
            break;
        case SocialAPISNSTypeQQZone:
        {
            //qq空间
            [_tencentQQ shareContentToQZoneWith:content];
        }
            break;
        case SocialAPISNSTypeQQ:
        {
            //QQ好友
            [_tencentQQ shareContentWith:content];
        }
            break;
        case SocialAPISNSTypeSinaWeibo:
        {
            //新浪微博
            [_sinaWeibo shareContentWith:content];
        }
            break;
        default:
            break;
    }
}

/**
- (void)shareContent:(NSMutableDictionary *)contentDic toPlatform:(SocialAPISNSType)platform {
    switch (platform) {
        case SocialAPISNSTypeWeChat:
        {
            [_weChat shareContent:contentDic toScene:WXSceneSession];
        }
            break;
        case SocialAPISNSTypeWeChatMoments:
        {
            [_weChat shareContent:contentDic toScene:WXSceneTimeline];
        }
            break;
        case SocialAPISNSTypeQQZone:
        {
            [_tencentQQ shareContentToQZone:contentDic];
        }
            break;
        case SocialAPISNSTypeQQ:
        {
            [_tencentQQ shareContent:contentDic];
        }
            break;
        case SocialAPISNSTypeSinaWeibo:
        {
            [_sinaWeibo shareContent:contentDic];
        }
            break;
            
        default:
            break;
    }
}
*/

/**
 *  处理第三方登录或者分享后返回当前APP的情况
 *
 *  @param url               需要处理的第三方跳转的URL
 *  @param sourceApplication 第三方来源标志
 *  @param annotation        描述注解
 *
 *  @return 是否跳转成功
 */
- (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL flag = NO;
    
    flag = [WeiboSDK handleOpenURL:url delegate:self.sinaWeibo] || [WXApi handleOpenURL:url delegate:self.weChat] || [TencentOAuth HandleOpenURL:url] || [QQApiInterface handleOpenURL:url delegate:self.tencentQQ];
    
    return flag;
}

@end
