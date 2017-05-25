//
//  KSServerMgr.h
//  kaisafax
//
//  Created by semny on 16/8/8.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSRequestBL.h"

#define KServerStatusNotification       @"ServerStatusNotification"


/**
 *  @author semny
 *
 *  服务端管理工具
 */
@interface KSServerMgr : KSRequestBL

/**
 *  初始化服务端管理工具单例对象
 *
 *  @return 服务端管理工具单例对象
 */
+(id)sharedInstance;

/**
 *  @author semny
 *
 *  获取服务端的接口服务状态
 */
- (void)doGetServerStatus;

@end
