//
//  UIDevice+Addition.h
//  kaisafax
//
//  Created by Semny on 14/12/17.
//  Copyright (c) 2014年 kaisafax. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  当前机器的编码
 *  属性值就不会变：相同的一个程序里面-相同的vindor-相同的设备。如果是这样的情况，那么这个值是不会相同的：相同的程序-相同的设备-不同的vindor，或者是相同的程序-不同的设备-无论是否相同的vindor。
 */
#define IDFVUUID [[[UIDevice currentDevice] identifierForVendor] UUIDString]





@interface SQDeviceUtil : NSObject

/**
 *  获取并且缓存uuid
 *
 *  @return 默认使用的是IDFV UIUID
 */
+ (NSString *)getUUID;

//+ (NSString *)getIMEI;

/**
 *  获取用户定义的手机别名
 *
 *  @return 用户别名
 */
+ (NSString *)getPhoneName;

/**
 *  获取设备名称
 *
 *  @return 设备名称
 */
+(NSString *)getDeviceName;

/**
 *  获取设备型号
 *
 *  @return 设备型号
 */
+(NSString *)getDeviceModel;

/**
 *  获取地方型号（国际化区域名称）
 *
 *  @return 地方型号（国际化区域名称）
 */
+(NSString *)getDeviceLocalModel;

/**
 *  手机系统版本
 *
 *  @return 手机系统版本
 */
+(NSString *)getSystemVersion;

@end
