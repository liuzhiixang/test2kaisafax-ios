//
//  SocialAPIWeChat.h
//  
//
//  Created by Semny on 14-9-23.
//  Copyright (c) 2014年 Semny. All rights reserved.
//

#import "SocialAPIBasePlatform.h"
#import "WXApi.h"
#import "WXHTTPRequest.h"

typedef enum : NSUInteger {
    WeChatSendTextRequest,
    WeChatSendImageRequest,
    WeChatSendLinkRequest,
} WeChatRequestType;


@interface SocialAPIWeChat : SocialAPIBasePlatform <WXApiDelegate>

@property (copy, nonatomic) NSString *code;
@property (copy, nonatomic) NSString *accessToken;

@property (copy, nonatomic) NSString *openID;
@property (assign, nonatomic) id <SocialAPIWeChatHttpRequestDelegate> httpDelegate;

/*! @brief 初始化实例对象，同时设置HTTPDelegate
 *
 * @param delegate HTTP代理对象
 * @return 实例
 */
- (instancetype)initWithHTTPDelegate:(id<SocialAPIWeChatHttpRequestDelegate>)delegate;

/*! 检查手机是否安装微信客户端
 * @return BOOL  YES---已经安装；NO---未安装
 */
- (BOOL)isWeChatInstalled;

/*! 授权登录
 * 通过该函数只能获取到授权临时票据code参数，要获取access_token，还要通过code参数加上AppID和AppSecret等，通过API换取。
 */
//- (void)ssoLogin;

- (void)getAccessToken;

//- (void)getUserInfo;

/**
 *  @author semny
 *
 *  朋友圈分享
 *
 *  @param content 分享内容
 *
 *  @return 序列号
 */
- (NSInteger)shareContentToTimelineWith:(SocialEntity *)content;

/**
 *  @author semny
 *
 *  朋友圈分享
 *
 *  @param content 分享内容
 *
 *  @return 序列号
 */
- (NSInteger)shareContentToTimelineWith:(SocialEntity *)content delegate:(id<SocialAPIDelegate>)delegate;

@end



