//
//  KSFundBL.h
//  kaisafax
//
//  Created by semny on 16/8/3.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSRequestBL.h"
/**
 *  @author semny
 *
 *  资金相关(交易记录)
 */
@interface KSFundBL : KSRequestBL

//1970
@property (nonatomic, assign) long long fromTime;
@property (nonatomic, assign) long long toTime;
////ALL 全部、DEPOSIT 充值、WITHDRAW 提现、INVEST/REPAY 投资/回款、REPAY 还款、LOAN/REPAY 借款/还款、TRANSFER 奖励
@property (nonatomic, copy) NSString *filterType;

/**
 *  加载最新的交易记录列表数据
 */
- (void)refreshUserFundRecords;

/**
 *  加载更多交易记录列表数据
 */
- (void)requestNextPageUserFundRecords;

@end
