//
//  KSAutoInvestBL.m
//  kaisafax
//
//  Created by semny on 17/5/5.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSAutoInvestBL.h"
#import "KSWebVC.h"

@implementation KSAutoInvestBL

//启动(开启)页面
+ (void)pushOpenAutoInvestPageWith:(UINavigationController*)navVC type:(NSInteger)type data:(NSDictionary*)data callback:(void (^)(NSDictionary *data))callback
{
    [self pushOpenAutoInvestPageWith:navVC needSetHidesBottomBarFlag:NO hidesBottomBarWhenPushed:NO type:type data:data callback:callback];
}

+ (void)pushOpenAutoInvestPageWith:(UINavigationController*)navVC hidesBottomBarWhenPushed:(BOOL)hidesBottomBarWhenPushed type:(NSInteger)type data:(NSDictionary*)data callback:(void (^)(NSDictionary *data))callback
{
    [self pushOpenAutoInvestPageWith:navVC needSetHidesBottomBarFlag:YES hidesBottomBarWhenPushed:hidesBottomBarWhenPushed type:type data:data callback:callback];
}

+ (void)pushOpenAutoInvestPageWith:(UINavigationController*)navVC needSetHidesBottomBarFlag:(BOOL)needSetHidesBottomBarFlag   hidesBottomBarWhenPushed:(BOOL)hidesBottomBarWhenPushed type:(NSInteger)type data:(NSDictionary*)data callback:(void (^)(NSDictionary *data))callback
{
    if(!navVC || ![navVC isKindOfClass:[UINavigationController class]])
    {
        ERROR(@"view controller is nil!");
        return;
    }
    
    if (!data || data.count <= 0)
    {
        return;
    }
    
    NSDictionary *params = data;
    NSString *urlString = [KSRequestBL createGetRequestURLWithTradeId:KOpenAutoInvestTradeId data:params error:nil];
    NSString *title = KAutoLoanOpen;
//    KSWebVC *vc =  [KSWebVC pushInController:navVC urlString:urlString title:title type:KSWebSourceTypeAutoLoan];
//    if (needSetHidesBottomBarFlag)
//    {
//        <#statements#>
//    }
//    [vc setCallback:callback];
    KSWebVC *vc  = [[KSWebVC alloc] initWithUrl:urlString title:title type:type];
    if (needSetHidesBottomBarFlag)
    {
        vc.hidesBottomBarWhenPushed = hidesBottomBarWhenPushed;
    }
    [vc setCallback:callback];
    [navVC pushViewController:vc animated:YES];
}

//启动(关闭)页面
+ (void)pushCloseAutoInvestPageWith:(UINavigationController*)navVC type:(NSInteger)type callback:(void (^)(NSDictionary *data))callback
{
    [self pushCloseAutoInvestPageWith:navVC needSetHidesBottomBarFlag:NO hidesBottomBarWhenPushed:NO type:type callback:callback];
}

+ (void)pushCloseAutoInvestPageWith:(UINavigationController*)navVC hidesBottomBarWhenPushed:(BOOL)hidesBottomBarWhenPushed type:(NSInteger)type callback:(void (^)(NSDictionary *data))callback
{
    [self pushCloseAutoInvestPageWith:navVC needSetHidesBottomBarFlag:YES hidesBottomBarWhenPushed:hidesBottomBarWhenPushed type:type callback:callback];
}

+ (void)pushCloseAutoInvestPageWith:(UINavigationController*)navVC needSetHidesBottomBarFlag:(BOOL)needSetHidesBottomBarFlag   hidesBottomBarWhenPushed:(BOOL)hidesBottomBarWhenPushed type:(NSInteger)type callback:(void (^)(NSDictionary *data))callback
{
    if(!navVC || ![navVC isKindOfClass:[UINavigationController class]])
    {
        ERROR(@"view controller is nil!");
        return;
    }
    
    NSDictionary *params = nil;
    NSString *urlString = [KSRequestBL createGetRequestURLWithTradeId:KCloseAutoInvestTradeId data:params error:nil];
    NSString *title = KAutoLoanClose;
    KSWebVC *vc  = [[KSWebVC alloc] initWithUrl:urlString title:title type:type];
    if (needSetHidesBottomBarFlag)
    {
        vc.hidesBottomBarWhenPushed = hidesBottomBarWhenPushed;
    }
    [vc setCallback:callback];
    [navVC pushViewController:vc animated:YES];
}
@end
