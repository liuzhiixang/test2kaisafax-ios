//
//  KSJXCustomerServiceMgr.m
//  kaisafax
//
//  Created by BeiYu on 2016/12/12.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSJXCustomerServiceMgr.h"
#import "JXMCSUserManager.h"

@implementation KSJXCustomerServiceMgr
#pragma mark - 佳信客服
#pragma mark - 调用客服API

-(void)jumpToCustomerCenter:(UINavigationController*)nav
{
    [[JXMCSUserManager sharedInstance] requestCSForUI:nav indexPath:1];
}

-(void)loginJXCustomer:(UINavigationController*)nav
{
    JXMCSUserManager *mgr = [JXMCSUserManager sharedInstance];
    @WeakObj(self);
    [mgr
     loginWithAppKey:KJXAppkey
     responseObject:^(BOOL success, id responseObject) {
         if (success) {
             [weakself loginJXSuccessed:nav];
         } else {
             dispatch_after(
                            dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.f * NSEC_PER_SEC)),
                            dispatch_get_main_queue(), ^{
                                JXError *error = responseObject;
                                if(error)
                                {
                                    [sJXHUD showMessage:@"佳信客服登录失败" duration:1.f];
                                }
                            });
         }
     }];
}

-(void)loginJXSuccessed:(UINavigationController*)nav
{
    [self jumpToCustomerCenter:nav];
}

+ (instancetype)sharedInstance
{
    static KSJXCustomerServiceMgr *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


@end
