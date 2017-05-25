//
//  SocialConfig.h
//  kaisafax
//
//  Created by semny on 16/8/19.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#ifndef SocialConfig_h
#define SocialConfig_h

//请求序列号
#define KResponseSeqNo       @"ResponseSeqNo"

typedef enum
{
    /**
     *  Semny, 2015-05-05
     */
    SSO_CMD_SinaWeiboLoginProcess = 10001, //新浪微博登录整个过程中统一返回的结果编号
    SSO_CMD_SinaWeiboSSOToken = 10002,
    SSO_CMD_SinaWeiboGetUserProcess = 10003, //新浪微博获取用户信息整个过程中统一返回的结果编号
    SSO_CMD_SinaWeiboUserInfo = 10004,
    SSO_CMD_SinaWeiboGetUserLogin = 10005,
    SSO_CMD_SinaWeiboShareProcess = 10006, //新浪微博分享整个过程中统一返回的结果编号
    SSO_CMD_SinaWeiboShare = 10007,
    SSO_CMD_SinaWeiboShareLogin = 10008,
    SSO_CMD_SinaWeiboLogout = 10009,
    /**
     *  Semny,2015-05-12 手机号登录
     */
    SSO_CMD_LoginMobileProcess = 10016,  //手机号登录整个过程中统一返回的结果编号
    SSO_CMD_BindMobileProcess = 10020  //手机号绑定整个过程中统一返回的结果编号
}SSO_CMD_CODE;

typedef enum
{
    SSO_API_RESULT_SHARE_ERROR = -2, //分享失败
    SSO_API_RESULT_LOGIN_ERROR = -1, //登录失败
}SSO_API_RESULT_CODE;

// 第三方SSO授权登录方式
typedef enum : NSUInteger {
    SocialAPISSOTypeWeChat = 1,
    SocialAPISSOTypeQQ,
    SocialAPISSOTypeSinaWeibo,
} SocialAPISSOType;

// 社交分享的目标平台
typedef enum : NSUInteger {
    SocialAPISNSTypeWeChat = 1,            //微信好友
    SocialAPISNSTypeWeChatMoments,     //微信朋友圈
    SocialAPISNSTypeQQZone,            //QQ空间
    SocialAPISNSTypeQQ,                //QQ好友
    SocialAPISNSTypeSinaWeibo,         //新浪微博
    SocialAPISNSTypeFaceToFace,         //面对面
} SocialAPISNSType;

#endif /* SocialConfig_h */
