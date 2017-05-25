//
//  SQLoggerMgr.m
//  kaisafax
//
//  Created by semny on 16/6/27.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "SQLoggerMgr.h"
#import "LogglyLogger.h"
#import "Logglyfields.h"
#import "LogglyFormatter.h"
#import "SQDeviceUtil.h"

//日志级别
//static const int ddLogLevel = DDLogLevelVerbose;
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;


@implementation SQLoggerMgr

/**
 *  日志工具单例方法
 *
 *  @return 单例对象
 */
+(id)sharedInstance
{
    static SQLoggerMgr *instance = nil;
    static dispatch_once_t lpredicate;
    dispatch_once(&lpredicate, ^{
        if (instance  == nil)
        {
            instance = [[SQLoggerMgr alloc] init];
        }
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init])
    {
        //初始化配置
        [self loggerConfig];
        DDLogInfo(@"%s, end of logger config!",__FUNCTION__);
    }
    return self;
}

#pragma mark - 日志初始化配置
- (void)loggerConfig
{
    // Enable XcodeColors
    setenv("XcodeColors", "YES", 0);
    
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    // setting logger colors
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor blackColor] backgroundColor:nil forFlag:DDLogFlagVerbose];//VERBOSE 黑色
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor blueColor] backgroundColor:nil forFlag:DDLogFlagDebug];//DEBUG 蓝色
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor orangeColor] backgroundColor:nil forFlag:DDLogFlagWarning];//WARN //橙色
    [[DDTTYLogger sharedInstance] setForegroundColor:UIColorFromHex(0x389867) backgroundColor:nil forFlag:DDLogFlagInfo];//INFO //绿色
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor redColor] backgroundColor:nil forFlag:DDLogFlagError];//ERROR //红色
    
    DDLogVerbose(@"Verbose");
    DDLogDebug(@"Debug");
    DDLogInfo(@"Info");
    DDLogWarn(@"Warn");
    DDLogError(@"Error");
    
    //日志记录的属性
    /*
     loglevel - CocoaLumberjack Log level
     timestamp - Timestamp in iso8601 format (required by Loggly)
     file - The name of the source file that logged the message
     fileandlinenumber - Source file and line number in that file (nice for doing facet searches in Loggly)
     appname - The Display name of your app
     appversion - The version of your app
     devicemodel - The device model
     devicename - The device name
     lang - The primary lang the app user has selected in Settings on the device
     osversion - the iOS version
     rawlogmessage - The log message that you sent, unparsed. This is also where simple non-JSON log messages will show up.
     sessionid - A generated random id, to let you search in loggly for log statements from the same session. You can override this random value by setting your own sessionid in the LogglyFields object.
     userid - A userid string. Note, you must set this userid yourself in the LogglyFields object. No default value.
     */
    LogglyFields *logglyFields = [[LogglyFields alloc] init];
    //手机的UUID
    NSString *deviceUUID = [SQDeviceUtil getUUID];
    if (!deviceUUID || deviceUUID == NULL)
    {
        //如果不存在UUID，就用如下手机参数组合
        NSString *phoneName = [SQDeviceUtil getPhoneName];
        NSString *deviceName = [SQDeviceUtil getDeviceName];
        NSString *deviceModel = [SQDeviceUtil getDeviceModel];
        deviceUUID = [NSString stringWithFormat:@"%@_%@_%@",phoneName,deviceName,deviceModel];
    }
    logglyFields.userid = deviceUUID;
    
    //日志格式
    LogglyFormatter *logglyFormatter = [[LogglyFormatter alloc] initWithLogglyFieldsDelegate:logglyFields];
    logglyFormatter.alwaysIncludeRawMessage = NO;
    
    //日志配置对象
    LogglyLogger *logglyLogger = [[LogglyLogger alloc] init];
    [logglyLogger setLogFormatter:logglyFormatter];
    //loggly服务器的key,暂时不适用
    logglyLogger.logglyKey = @"enter-your-loggly-key-here";
    // 存储日志时间间隔为15秒.
    logglyLogger.saveInterval = 15;
    
    [DDLog addLogger:logglyLogger];
    
}

- (void)loggerInfo:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2)
{
    va_list args;
    if (format) {
        va_start(args, format);
        NSString *outStr = [[NSString alloc] initWithFormat:format arguments:args];
        DDLogInfo(@"%@",outStr);
        va_end(args);
    }
}

- (void)loggerDebug:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2)
{
    va_list args;
    if (format) {
        va_start(args, format);
        NSString *outStr = [[NSString alloc] initWithFormat:format arguments:args];
        DDLogDebug(@"%@",outStr);
        va_end(args);
    }
}

- (void)loggerWarn:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2)
{
    va_list args;
    if (format) {
        va_start(args, format);
        NSString *outStr = [[NSString alloc] initWithFormat:format arguments:args];
        DDLogWarn(@"%@",outStr);
        va_end(args);
    }
}

- (void)loggerError:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2)
{
    va_list args;
    
    if (format) {
        va_start(args, format);
        NSString *outStr = [[NSString alloc] initWithFormat:format arguments:args];
        DDLogError(@"%@",outStr);
        va_end(args);
    }
}
@end
