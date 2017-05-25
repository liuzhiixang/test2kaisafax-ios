//
//  KSOpenAccountBL.h
//  kaisafax
//
//  Created by semny on 17/5/4.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSRequestBL.h"

@interface KSOpenAccountBL : KSRequestBL

//启动开户页面
+ (void)pushOpenAccountPageWith:(UINavigationController*)navVC;
+ (void)pushOpenAccountPageWith:(UINavigationController*)navVC type:(NSInteger)type;
+ (void)pushOpenAccountPageWith:(UINavigationController*)navVC hidesBottomBarWhenPushed:(BOOL)hidesBottomBarWhenPushed;
/**
 *  @author semny
 *
 *  启动开户页面
 *
 *  @param navVC                    push启动的nav
 *  @param hidesBottomBarWhenPushed 是否隐藏bottombar
 *  @param type                     启动开户页面的来源，KSWebSourceType,无此属性的都是根据一下代码判断是哪个流程的
                                    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate; 
                                    NSInteger selectedIndex = appDelegate.tabbarVC.selectedIndex;
 */
+ (void)pushOpenAccountPageWith:(UINavigationController*)navVC hidesBottomBarWhenPushed:(BOOL)hidesBottomBarWhenPushed type:(NSInteger)type;
@end
