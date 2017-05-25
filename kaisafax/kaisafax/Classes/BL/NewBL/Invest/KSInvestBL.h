//
//  KSInvestBL.h
//  kaisafax
//
//  Created by semny on 16/7/25.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBRequestBL.h"

/**
 *  @author semny
 *
 *  投资标的列表的Batch请求，投资标的详情请求
 */
@interface KSInvestBL : KSBRequestBL

/**
 *  @author semny
 *
 *  加载投资标的列表数据(新手标＋普通标)
 */
- (void)refreshInvestList;

/**
 *  加载更多投资列表数据（暂时只加载下一页普通的投资列表）
 */
- (void)requestNextPageInvestList;

///**
// *  @author semny
// *
// *  获取投资标的的详情数据
// *
// *  @param loanId 标的id
// */
//- (NSInteger)doGetInvestDetailByLoanId:(NSString *)loanId;
//
///**
// *  @author semny
// *
// *  获取投资记录
// *
// *  @param loanId 标的id
// */
//- (NSInteger)doGetInvestRecordByLoanId:(NSString *)loanId;
//
///**
// *  @author semny
// *
// *  获取投资标的回款计划数据(登录用户)
// *
// *  @param investId 投资记录id
// */
//- (NSInteger)doGetInvestRepaysByInvestId:(NSString *)investId;

@end
