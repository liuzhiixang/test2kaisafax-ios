//
//  KSStatisticalMgr.h
//  kaisafax
//
//  Created by semny on 16/8/18.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 REALTIME只在“集成测试”设备的DEBUG模式下有效，其它情况下的REALTIME会改为使用BATCH策略。
 */
typedef enum {
    ReportPolicyTypeRealTime = 0,       //实时发送(只在“集成测试”设备的DEBUG模式下有效)
    ReportPolicyTypeBatch = 1,          //启动时批量发送
    ReportPolicyTypeInterval = 6,  //最小间隔发送           ([90-86400]s, default 90s)
    ReportPolicyTypeSmart = 8,
} ReportPolicyType;

@interface KSStatisticalMgr : NSObject
/**
 *  @author semny
 *
 *  统计管理工具单例
 *
 *  @return 统计单例工具
 */
+(KSStatisticalMgr*)sharedInstance;

#pragma mark - 开启操作
/**
 *  @author semny
 *
 *  配置并开启统计工具
 */
- (void)start;

/**
 *  @author semny
 *
 *  自动页面时长统计, 开始记录某个页面展示时长(必须与endLogPageView:配合使用)
 *
 *  @param pageName 统计的页面名称
 */
- (void)beginLogPageView:(NSString *)pageName;

/**
 *  @author semny
 *
 *  自动页面时长统计, 结束记录某个页面展示时长
 *
 *  @param pageName 统计的页面名称
 */
- (void)endLogPageView:(NSString *)pageName;

@end
