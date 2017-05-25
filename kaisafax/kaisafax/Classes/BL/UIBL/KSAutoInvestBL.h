//
//  KSAutoInvestBL.h
//  kaisafax
//
//  Created by semny on 17/5/5.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSRequestBL.h"

@interface KSAutoInvestBL : KSRequestBL

//启动(开启)页面
+ (void)pushOpenAutoInvestPageWith:(UINavigationController*)navVC type:(NSInteger)type data:(NSDictionary*)data callback:(void (^)(NSDictionary *data))callback;
+ (void)pushOpenAutoInvestPageWith:(UINavigationController*)navVC hidesBottomBarWhenPushed:(BOOL)hidesBottomBarWhenPushed type:(NSInteger)type data:(NSDictionary*)data callback:(void (^)(NSDictionary *data))callback;

//启动(关闭)页面
+ (void)pushCloseAutoInvestPageWith:(UINavigationController*)navVC type:(NSInteger)type callback:(void (^)(NSDictionary *data))callback;
+ (void)pushCloseAutoInvestPageWith:(UINavigationController*)navVC hidesBottomBarWhenPushed:(BOOL)hidesBottomBarWhenPushed type:(NSInteger)type callback:(void (^)(NSDictionary *data))callback;

@end
