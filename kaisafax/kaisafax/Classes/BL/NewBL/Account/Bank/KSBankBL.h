//
//  KSBankBL.h
//  kaisafax
//
//  Created by semny on 16/8/16.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSRequestBL.h"

typedef NS_ENUM(NSUInteger,KSBankListType)
{
    KSBankListTypeQuickPay=0,            //快捷
    KSBankListTypeInternetBank=1,        //网银
};

@interface KSBankBL : KSRequestBL

/**
 *  @author semny
 *
 *  获取银行列表(充值等操作中用到的获取支持的银行信息)
 *
 *  @param type 列表类型(QP:快捷支付,B2C:网银支付)
 *
 *  @return 序列号
 */
- (NSInteger)doGetBankListWith:(KSBankListType)type;

@end
