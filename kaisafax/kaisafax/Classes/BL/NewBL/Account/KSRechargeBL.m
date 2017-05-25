//
//  KSRechargeBL.m
//  kaisafax
//
//  Created by semny on 16/8/11.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSRechargeBL.h"
#import "KSUserMgr.h"

@implementation KSRechargeBL

/**
 *  @author semny
 *
 *  获取充值信息(快捷充值卡，银行，第三方账户<汇付>)
 *
 *  @return 序列号
 */
//- (NSInteger)doGetRechargeInfo
//{
//    return [self doGetRechargeInfoWith];
//}

/**
 *  @author semny
 *
 *  获取充值信息(快捷充值卡，银行，第三方账户<汇付>)
 *
 *  @param actionFlag 操作标识(差额充值等)
 *
 *  @return 序列号
 */
- (NSInteger)doGetRechargeInfo
{
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    NSString *imeiStr = USER_SESSIONID;
//    if(imeiStr && imeiStr.length > 0)
//    {
//        [params setObject:imeiStr forKey:KUserIMEIKey];
//    }
//    if (actionFlag > 0)
//    {
//        NSNumber *actionFlagNum = [NSNumber numberWithInteger:actionFlag];
//        [params setObject: forKey:kInvestLoanIdKey];
//    }
    
    NSString *tradeId = KGetRechargeInfoTradeId;
    return [self requestWithTradeId:tradeId data:nil];
}

@end
