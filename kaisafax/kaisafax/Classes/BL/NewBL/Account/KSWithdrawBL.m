//
//  KSWithdrawBL.m
//  kaisafax
//
//  Created by semny on 16/8/19.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSWithdrawBL.h"
#import "KSUserMgr.h"

@implementation KSWithdrawBL

/**
 *  @author semny
 *
 *  获取提现信息(默认提现卡，银行，其他信息)
 *
 *  @return 序列号
 */
- (NSInteger)doGetWithdrawInfo
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    NSString *imeiStr = USER_SESSIONID;
//    if(imeiStr && imeiStr.length > 0)
//    {
//        [params setObject:imeiStr forKey:KUserIMEIKey];
//    }
    
    NSString *tradeId = KGetWithdrawInfoTradeId;
    return [self requestWithTradeId:tradeId data:params];
}

@end
