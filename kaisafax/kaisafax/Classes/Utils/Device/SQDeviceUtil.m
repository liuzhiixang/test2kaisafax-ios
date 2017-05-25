//
//  UIDevice+Addition.m
//  kaisafax
//
//  Created by Semny on 14/12/17.
//  Copyright (c) 2014年 kaisafax. All rights reserved.
//

#import "SQDeviceUtil.h"

@implementation SQDeviceUtil

/**
 *  获取uuid
 *
 *  @return 默认使用的是IDFV UIUID
 */
+ (NSString *)getUUID
{
    return IDFVUUID;
}

//extern NSString *CTSIMSupportCopyMobileSubscriberIdentity();
//+(NSString *)getIMEI
//{
//    return CTSIMSupportCopyMobileSubscriberIdentity();
//}
+(NSString *)getPhoneName
{
    NSString *userPhoneName = [[UIDevice currentDevice] name];
    return userPhoneName;
}

+(NSString *)getDeviceName
{
    NSString *systemName = [[UIDevice currentDevice] systemName];
    return systemName;
}

+(NSString *)getDeviceModel
{
    //手机型号
    NSString *phoneModel = [[UIDevice currentDevice] model];
    return phoneModel;
}

+(NSString *)getDeviceLocalModel
{
    //地方型号（国际化区域名称）
    NSString *localPhoneModel = [[UIDevice currentDevice] localizedModel];
    return localPhoneModel;
}

+(NSString *)getSystemVersion
{
    //手机系统版本
    NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
    return phoneVersion;
}

@end
