//
//  KSStatisticalMgr.m
//  kaisafax
//
//  Created by semny on 16/8/18.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSStatisticalMgr.h"
#import <UMMobClick/MobClick.h>

@interface KSStatisticalMgr()

@end

@implementation KSStatisticalMgr
/**
 *  @author semny
 *
 *  统计管理工具单例
 *
 *  @return 统计单例工具
 */
+(KSStatisticalMgr*)sharedInstance
{
    static KSStatisticalMgr *instance;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        if (instance  == nil)
        {
            instance = [[KSStatisticalMgr alloc] init];
        }
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self configDefault];
    }
    return self;
}

#pragma mark - 默认配置
- (void)configDefault
{
#ifdef __ONLINE__
    //设置是否打印sdk的log信息, 默认NO(不打印log).
    [self setLogEnabled:YES];
#endif
    //上传崩溃日志
    [self setCrashReportEnabled:YES];
    //对日志加密
    [self setEncryptEnabled:YES];
    //密钥
    UMConfigInstance.appKey = @"579ec1e5e0f55aeb95001b62";
    //UMConfigInstance.secret = @"secretstringaldfkals";
    UMConfigInstance.eSType = E_UM_NORMAL;
    //启动时批量发送
    UMConfigInstance.ePolicy = BATCH;
    //为nil或@""时，默认会被当作@"App Store"渠道
    //UMConfigInstance.channelId=@"";
    
    //获取APP的version name; 如： 2.0.0
    NSString *versionName = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
    [self setAppVersion:versionName];
}

#pragma mark - 参数设置
- (void)setAppVersion:(NSString *)version
{
    if (version && version.length > 0)
    {
        //参数为NSString * 类型,自定义app版本信息，如果不设置，默认从CFBundleVersion里取
        [MobClick setAppVersion:version];
    }
}

- (void)setCrashReportEnabled:(BOOL)flag
{
    [MobClick setCrashReportEnabled:flag];
}

- (void)setLogEnabled:(BOOL)flag
{
    [MobClick setLogEnabled:flag];
}

- (void)setBackgroundTaskEnabled:(BOOL)flag
{
    //友盟SDK已经屏蔽，有些版本原来会导致崩溃
    //[MobClick setBackgroundTaskEnabled:flag];
}

- (void)setEncryptEnabled:(BOOL)flag
{
    [MobClick setEncryptEnabled:flag];
}

- (void)setLogSendInterval:(BOOL)flag
{
    [MobClick setLogSendInterval:flag];
}

//设置日志延迟发送
- (void)setLatency:(NSInteger)second
{
    //友盟SDK已经屏蔽
    //int temp = (int)second;
    //[MobClick setLatency:temp];
}

#pragma mark - 开启操作
/**
 *  @author semny
 *
 *  配置并开启统计工具
 */
- (void)start
{
#ifndef DEBUG
    [MobClick startWithConfigure:UMConfigInstance];
#endif
}

/**
 *  @author semny
 *
 *  自动页面时长统计, 开始记录某个页面展示时长(必须与endLogPageView:配合使用)
 *
 *  @param pageName 统计的页面名称
 */
- (void)beginLogPageView:(NSString *)pageName
{
    [MobClick beginLogPageView:pageName];
    DEBUGG(@"%s, %@", __FUNCTION__, pageName);
}

/**
 *  @author semny
 *
 *  自动页面时长统计, 结束记录某个页面展示时长
 *
 *  @param pageName 统计的页面名称
 */
- (void)endLogPageView:(NSString *)pageName
{
    [MobClick endLogPageView:pageName];
    DEBUGG(@"%s, %@", __FUNCTION__, pageName);
}
@end
