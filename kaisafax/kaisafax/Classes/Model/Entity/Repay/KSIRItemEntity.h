//
//  KSIRItemEntity.h
//  kaisafax
//
//  Created by semny on 16/8/5.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"
#import "KSDueDateEntity.h"

//投资还款状态 0-未还款,1-已逾期,2-已还清,3-已转让,4-已垫付
typedef NS_ENUM(NSUInteger, KSInvestRepayStatus)
{
    KSInvestRepayStatusUnRepay = 0, //未还款
    KSInvestRepayStatusOverdue = 1, //已逾期
    KSInvestRepayStatusCleared = 2, //已还清
    KSInvestRepayStatusTransfer = 3, //已转让
    KSInvestRepayStatusAdvances = 4, //已垫付
};
/**
 *  @author semny
 *
 *  投资回款计划单条数据
 */
@interface KSIRItemEntity : KSBaseEntity

//@property (nonatomic, assign) CGFloat ownerFee;
// 代缴物业费
@property (nonatomic, copy) NSString *ownerFee;
// 期数
@property (nonatomic, assign) NSInteger period;
// 应收本金
@property (nonatomic, copy) NSString *repayPrincipal;
// 收益
@property (nonatomic, copy) NSString *repayProfit;
//还款状态  0-未还款,1-已逾期,2-已还清,3-已转让,4-已垫付
@property (nonatomic, assign) NSInteger status;
//到期时间
@property (nonatomic, strong) KSDueDateEntity *dueDate;

//获取状态字符串
-(NSString*)getStatusText;

//判断是否为业主
- (BOOL)isOwner;

@end

