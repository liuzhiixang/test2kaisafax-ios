//
//  KSReportMgr.h
//  kaisafax
//
//  Created by semny on 16/12/26.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSRequestBL.h"

@interface KSReportMgr : KSRequestBL

/**
 *  初始化服务端上报管理工具单例对象
 *
 *  @return 服务端上报管理工具单例对象
 */
+ (id)sharedInstance;

/**
 *  @author semny
 *
 *  设备信息上报
 */
- (NSInteger)doSendDeviceReport;

//获取guid
+ (NSString *)getDevInfoGuid;
@end
