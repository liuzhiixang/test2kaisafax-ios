//
//  KSServerMgr.m
//  kaisafax
//
//  Created by semny on 16/8/8.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSServerMgr.h"
#import "KSServerAlert.h"

#define KStatusOnline   @"online"
#define KStatusOffline   @"offline"

@interface KSServerMgr()<ServerStatusViewDelegate>


@end

@implementation KSServerMgr

/**
 *  初始化服务端管理工具单例对象
 *
 *  @return 服务端管理工具单例对象
 */
+(id)sharedInstance
{
    static KSServerMgr *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        if (instance  == nil)
        {
            instance = [[KSServerMgr alloc] init];
        }
    });
    return instance;
}

/**
 *  @author semny
 *
 *  获取服务端的接口服务状态
 */
- (void)doGetServerStatus
{
    NSString *tradeId = KServerStatusTradeId;
    NSString *url = [NSString stringWithFormat:@"%@/%@", SX_HOST, tradeId];
    //请求
    [self requestWithTradeId:tradeId data:nil URL:url httpMethod:SQRequestMethodPost];
}

#pragma mark -
#pragma mark ------------回调（子类没有实现，默认调用父类的回调）-----------
- (void)requestFinished:(SQBaseRequest *)request
{
    KSBRequest *brequest = nil;
    NSString *tradeId = nil;
    if (request && [request isKindOfClass:[KSBRequest class]])
    {
        brequest = (KSBRequest*)request;
        tradeId = brequest.tradeId;
    }
   
    DEBUGG(@"%s tradeId:%@", __FUNCTION__, tradeId);
    //报文结果
    id responseObj = brequest.responseObject;
    NSDictionary *dict = nil;
    
    //服务器状态接口
    if([tradeId isEqualToString:KServerStatusTradeId])
    {
        if (responseObj && [responseObj isKindOfClass:[NSDictionary class]])
        {
            dict = (NSDictionary *)responseObj;
            NSString *status = [dict objectForKey:kStatusKey];
            
            //正常状态
            if ([KStatusOnline isEqualToString:status])
            {
                //发正常通知
                [self handleOnlineStatus];
                return;
            }
        }
        
        //发异常通知
        [self handleOfflineStatus];
    }
}

- (void)requestFailed:(SQBaseRequest *)request
{
    KSBRequest *brequest = nil;
    NSString *tradeId = nil;
    if (request && [request isKindOfClass:[KSBRequest class]])
    {
        brequest = (KSBRequest*)request;
        tradeId = brequest.tradeId;
    }
    
    DEBUGG(@"%s tradeId:%@", __FUNCTION__, tradeId);
    
    //服务器状态接口
    if([tradeId isEqualToString:KServerStatusTradeId])
    {
        //发异常通知
        //[self handleOfflineStatus];
    }
}

- (void)handleOnlineStatus
{
    //隐藏服务器维护提示框
    [[KSServerAlert sharedInstance] hiddenServerPopupWindow];
    //发服务状态正常通知
    [[NSNotificationCenter defaultCenter] postNotificationName:KServerStatusNotification object:[NSNumber numberWithBool:YES]];
}

- (void)handleOfflineStatus
{
    //显示服务器维护提示框
    [[KSServerAlert sharedInstance] showServerPopupWindowWith:KServerStatusShowCommentText1 comment2:KServerStatusShowCommentText2 comment3:KServerStatusShowCommentText3 actionTitle:KServerStatusShowActionTitle delegate:self];
    //发服务状态异常通知
    [[NSNotificationCenter defaultCenter] postNotificationName:KServerStatusNotification object:[NSNumber numberWithBool:NO]];
}

#pragma mark -
- (void)serverViewCancel:(KSServerStatusView *)serverView
{
    DEBUGG(@"%s", __FUNCTION__);
    //隐藏服务器维护提示框
    [[KSServerAlert sharedInstance] hiddenServerPopupWindow];
}
@end
