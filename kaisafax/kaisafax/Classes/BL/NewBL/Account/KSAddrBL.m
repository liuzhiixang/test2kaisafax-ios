//
//  KSAddrBL.m
//  kaisafax
//
//  Created by BeiYu on 2016/11/22.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSAddrBL.h"
//receiverName:<String>,//收货人
//receiverMobile:<String>,//联系手机号
//province:<String>,//省级编码
//city:<String>,//市级编码
//county:<String>,//区县级编码
//address:<String>,//详细地址
//zipCode:<String>,//邮编
@implementation KSAddrBL
- (NSInteger)doSetAddrWithName:(NSString*)receiverName mobile:(NSString*)receiverMobile province:(NSString*)province
                          city:(NSString*)city county:(NSString*)county address:(NSString*)address zipCode:(NSString*)zipCode
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];

    params[kReceiverNameKey] = receiverName;
    params[kReceiverMobileKey] = receiverMobile;
    params[kProvinceKey] = province;
    params[kCityKey] = city;
    params[kCountyKey] = county;
    params[kAddressKey] = address;
    params[kZipCodeKey] = zipCode;
    
    NSString *tradeId = KModifyAddr;
    //请求
    return [self requestWithTradeId:tradeId data:params];
}
@end
