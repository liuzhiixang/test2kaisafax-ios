//
//  KSADMgr.h
//  kaisafax
//
//  Created by semny on 16/10/19.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSRequestBL.h"
#import "KSAdvertEntity.h"

@interface KSADMgr : KSRequestBL

/**
 *  初始化服务端广告管理工具单例对象
 *
 *  @return 服务端广告管理工具单例对象
 */
+ (id)sharedInstance;

/**
 *  @author semny
 *
 *  判断 是否需要显示广告启动页
 *
 *  @return YES：需要显示；NO：不需要显示；
 */
+ (BOOL)checkNeedShowADStartPage;

/**
 *  @author semny
 *
 *  判断 是否需要显示服务端推送的广告启动页
 *
 *  @return YES：需要显示；NO：不需要显示；
 */
+ (BOOL)checkNeedShowADPushPage;

/**
 *  @author semny
 *
 *  设置不需要显示广告启动页
 */
+ (void)setUnshowFlagADStartPage;

//获取远程的广告数据
+ (KSAdvertEntity *)getPushADData;

#pragma mark - 弹出广告页面
+ (void)presentADPageBy:(UIViewController *)controller;

/**
 *  @author semny
 *
 *  获取服务端广告
 */
- (void)doGetServerADConfig;

@end
