//
//  KSRechargeBL.h
//  kaisafax
//
//  Created by semny on 16/8/11.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSRequestBL.h"
#import "KSRechargeEntity.h"

/**
 *  @author semny
 *
 *  充值相关
 */
@interface KSRechargeBL : KSRequestBL

/**
 *  @author semny
 *
 *  获取充值信息(快捷充值卡，银行，第三方账户<汇付>)
 *
 *  @return 序列号
 */
- (NSInteger)doGetRechargeInfo;

/**
 *  @author semny
 *
 *  获取充值信息(快捷充值卡，银行，第三方账户<汇付>)
 *
 *  @param actionFlag 操作标识(差额充值等)
 *
 *  @return 序列号
 */
//- (NSInteger)doGetRechargeInfoWith:(NSInteger)actionFlag;

@end
