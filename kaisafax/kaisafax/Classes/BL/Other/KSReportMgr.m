//
//  KSReportMgr.m
//  kaisafax
//
//  Created by semny on 16/12/26.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSReportMgr.h"
#import "SQDeviceUtil.h"
#import <NSHash/NSString+NSHash.h>

@interface KSReportMgr()

@property (strong, nonatomic) NSString *guid;

@end

@implementation KSReportMgr

/**
 *  初始化服务端上报管理工具单例对象
 *
 *  @return 服务端上报管理工具单例对象
 */
+ (id)sharedInstance
{
    static KSReportMgr *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        if (instance  == nil)
        {
            instance = [[KSReportMgr alloc] init];
        }
    });
    return instance;
}

/**
 *  @author semny
 *
 *  设备信息上报
 */
- (NSInteger)doSendDeviceReport
{
//    //imei:<String>  //由于imei在当前API中当作用户登录信息使用，使用deviceImei代替
//platformType:<String> //平台类型 ios/android
//guid:<String> //客户端生成的设备唯一标示
//    /**
//     guid生成规则：
//     deviceId         deviceId      Y         Android：自己生成(根据硬件信息); IOS：IDFA，手机唯一编号，字符串
//     deviceModel     设备型号     N         设备型号，字符串
//     manufactor     手机品牌     N         手机品牌，字符串
//     platformType     平台     Y         ios/android
//     以上参数json格式字符串，Base64加密；
//     */
//macAddr:<String> //Mac地址     N         字符串(Base64)
//deviceImei:<String> //imei    N         android的imei,由于需要用户提供权限，所以不作为guid必选参数(Base64)，IOS：IDFA，手机唯一编号，字符串
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *guidStr = [self createGUID];
    if (guidStr)
    {
        [params setObject:guidStr forKey:kGuidKey];
    }
    NSString *deviceId = [SQDeviceUtil getUUID];
    if (deviceId)
    {
        [params setObject:deviceId forKey:kDeviceImeiKey];
    }
    NSString *tradeId = KDeviceReportTradeId;
    
    //请求
    long long seqNo = [self requestWithTradeId:tradeId data:params];
    
    //缓存guid
    [self.class setDevInfoGuid:guidStr];
    
    //请求记录
    [self updateRecordStackBySeqno:seqNo data:guidStr];
    //请求
    return seqNo;
}

- (NSString *)createGUID
{
    NSMutableDictionary *guidDict = [NSMutableDictionary dictionary];
    NSString *deviceId = [SQDeviceUtil getUUID];
    if (deviceId)
    {
        [guidDict setObject:deviceId forKey:@"deviceId"];
    }
    NSString *deviceModel = [SQDeviceUtil getDeviceModel];
    if (deviceModel)
    {
        [guidDict setObject:deviceModel forKey:@"deviceModel"];
    }
    NSInteger platformType = kPlatformTypeValue;
    [guidDict setObject:@(platformType) forKey:kPlatformTypeKey];
    NSString *manufactor = kManufactorValue;
    [guidDict setObject:manufactor forKey:kManufactorKey];
    NSString *guidStr = [guidDict yy_modelToJSONString];
    guidStr = [guidStr MD5] ;
    return guidStr;
}

#pragma mark -
#pragma mark -----------通知结果处理(网络请求回调使用)--------------
- (void)succeedCallbackWithResponse:(KSResponseEntity *)resp
{
    NSString *tempCmdId = resp.tradeId;
    long long seqNo = resp.sid;
    //包体数据
    KSResponseEntity *resultResp = resp;
    //设备信息上报
    if ([KDeviceReportTradeId isEqualToString:tempCmdId])
    {
        //设备信息
        NSString *guidStr = [self objectInRecordStackForSeqno:seqNo];
        
        if (!guidStr || guidStr.length <= 0)
        {
            return;
        }
    }
    //调用父类的回调
    [super succeedCallbackWithResponse:resultResp];
}

+ (void)setDevInfoGuid:(NSString*)guid
{
    if (guid && guid.length > 0)
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:guid forKey:kUpdateDevInfoGUID];
        [userDefaults synchronize];
    }
}

+ (NSString *)getDevInfoGuid
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *guidStr = [userDefaults objectForKey:kUpdateDevInfoGUID];
    return guidStr;
}

@end
