//
//  KSLogger.h
//  kaisafax
//
//  Created by semny on 16/6/26.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#ifndef KSLogger_h
#define KSLogger_h

//0表示关闭，1表示打开文件记录日志
//#define kEnableLog2File 1

#import <Foundation/Foundation.h>
#import "SQLoggerMgr.h"

//暂时打包上线版本关闭日志，后续可以手动控制
#ifdef __ONLINE__
    #define __SELF_DEFING_CLOSELOGGER__ 1
#endif
//#define __SELF_DEFING_CLOSELOGGER__ 1

#ifndef __SELF_DEFING_CLOSELOGGER__

#define INFO(format, ...)   [[SQLoggerMgr sharedInstance] loggerInfo:(format), ##__VA_ARGS__]
#define DEBUGG(format, ...) [[SQLoggerMgr sharedInstance] loggerDebug:(format), ##__VA_ARGS__]
#define WARN(format, ...)   [[SQLoggerMgr sharedInstance] loggerWarn:(format), ##__VA_ARGS__]
#define ERROR(format, ...)  [[SQLoggerMgr sharedInstance] loggerError:(format), ##__VA_ARGS__]

#else

#define INFO(format, ...)
#define DEBUGG(format, ...)
#define WARN(format, ...)
#define ERROR(format, ...)

#endif

#endif /* KSLogger_h */
