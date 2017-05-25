//
//  KSInvestAboutBL.h
//  kaisafax
//
//  Created by semny on 16/8/17.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSRequestBL.h"

#define KInvestRecordPageMaxCount  20
/**
 *  @author semny
 *
 *  投资(详情)相关的接口
 */
@interface KSInvestAboutBL : KSRequestBL

/**
 *  @author semny
 *
 *  获取投资标的的详情数据
 *
 *  @param loanId 标的id
 */
- (NSInteger)doGetInvestDetailByLoanId:(long long)loanId;

/**
 *  @author semny
 *
 *  获取投资记录
 *
 *  @param loanId 标的id
 */
- (NSInteger)doGetInvestRecordByLoanId:(long long)loanId;

/**
 *  @author yubei
 *
 *  获取投资记录
 *
 *  @param loanId 标的id
 */

- (void)doGetNextPageInvestRecordByLoanId:(long long)loanId;


/**
 *  @author semny
 *
 *  获取投资标的回款计划数据(登录用户)
 *
 *  @param investId 投资记录id
 */
- (NSInteger)doGetInvestRepaysByInvestId:(long long)investId;

@end
