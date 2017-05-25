//
//  KSOpenAccountBL.m
//  kaisafax
//
//  Created by semny on 17/5/4.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSOpenAccountBL.h"
#import "KSOpenAccountVC.h"

@implementation KSOpenAccountBL

+ (void)pushOpenAccountPageWith:(UINavigationController*)navVC
{
    [self pushOpenAccountPageWith:navVC needSetHidesBottomBarFlag:NO hidesBottomBarWhenPushed:NO];
}

+ (void)pushOpenAccountPageWith:(UINavigationController*)navVC type:(NSInteger)type
{
    [self pushOpenAccountPageWith:navVC needSetHidesBottomBarFlag:NO hidesBottomBarWhenPushed:NO type:type];
}

+ (void)pushOpenAccountPageWith:(UINavigationController*)navVC hidesBottomBarWhenPushed:(BOOL)hidesBottomBarWhenPushed
{
    [self pushOpenAccountPageWith:navVC needSetHidesBottomBarFlag:YES hidesBottomBarWhenPushed:hidesBottomBarWhenPushed];
}

+ (void)pushOpenAccountPageWith:(UINavigationController*)navVC needSetHidesBottomBarFlag:(BOOL)needSetHidesBottomBarFlag  hidesBottomBarWhenPushed:(BOOL)hidesBottomBarWhenPushed
{
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSInteger selectedIndex = appDelegate.tabbarVC.selectedIndex;
    NSInteger type = KSWebSourceTypeInvestDetail;
    if (selectedIndex == 2)
    {
        type = KSWebSourceTypeAccount;
    }
    [self pushOpenAccountPageWith:navVC needSetHidesBottomBarFlag:needSetHidesBottomBarFlag hidesBottomBarWhenPushed:hidesBottomBarWhenPushed type:type];
}

+ (void)pushOpenAccountPageWith:(UINavigationController*)navVC hidesBottomBarWhenPushed:(BOOL)hidesBottomBarWhenPushed type:(NSInteger)type
{
    [self pushOpenAccountPageWith:navVC needSetHidesBottomBarFlag:YES hidesBottomBarWhenPushed:hidesBottomBarWhenPushed type:type];
}

+ (void)pushOpenAccountPageWith:(UINavigationController*)navVC needSetHidesBottomBarFlag:(BOOL)needSetHidesBottomBarFlag  hidesBottomBarWhenPushed:(BOOL)hidesBottomBarWhenPushed type:(NSInteger)type
{
    if(!navVC || ![navVC isKindOfClass:[UINavigationController class]])
    {
        ERROR(@"view controller is nil!");
        return;
    }
    
    NSString *urlStr = [KSRequestBL createGetRequestURLWithTradeId:KOpenAccountTradeId data:nil error:nil];
    //开托管账户
    KSOpenAccountVC *openAccountVC = [[KSOpenAccountVC alloc] initWithUrl:urlStr title:KOpenAccountTitle type:type];
    if (needSetHidesBottomBarFlag)
    {
        openAccountVC.hidesBottomBarWhenPushed = hidesBottomBarWhenPushed;
    }
    [navVC pushViewController:openAccountVC animated:YES];
}

@end
