//
//  KSNewbeeEntity.h
//  kaisafax
//
//  Created by semny on 16/8/1.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"
#import "KSLoanItemEntity.h"

/**
 *  @author semny
 *
 *  新手标数据
 */
@interface KSNewbeeEntity : KSBaseEntity

//新手标可投次数
//@property (nonatomic, assign) NSInteger newbeeTime;
//新手标是否可投
@property (nonatomic, assign) BOOL testLoan;
//合同模板ID 新手标无模板
@property (nonatomic, copy) NSString *contract;
//服务器时间
@property (nonatomic, assign) NSInteger serverTime;
//新手标可投金额
@property (nonatomic, assign) NSInteger newbeeAmount;
//新手标投资限额
@property (nonatomic, assign) NSInteger newbeeLimitAmount;
#pragma mark -sticky
//标的信息
@property (nonatomic, strong) KSLoanItemEntity *loan;

//是否投满了
- (BOOL)isCanInvest;
//新手标状态文字
- (NSString *)getNewbeeStatusText;

//格式化
- (NSUInteger)getCanInvestMaxInAvailable:(NSUInteger)available;
@end
