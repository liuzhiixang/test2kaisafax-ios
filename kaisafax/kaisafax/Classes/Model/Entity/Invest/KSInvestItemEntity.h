//
//  KSInvestItemEntity.h
//  kaisafax
//
//  Created by semny on 16/8/5.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"
#import "KSDurationEntity.h"

//投资状态 3-投标中,6-还款中,8-已还清
typedef NS_ENUM(NSUInteger, KSDoInvestStatus)
{
    KSDoInvestStatusFrozen = 3, //投标中
    KSDoInvestStatusLoaned = 6, //还款中
    KSDoInvestStatusCleared = 8, //已还清
};

/**
 *  @author semny
 *
 *  用户投资记录单条数据中的投资信息
 */
@interface KSInvestItemEntity : KSBaseEntity
//投资ID
@property (nonatomic, assign) long long iiId;
//用户ID
@property (nonatomic, assign) long long userId;
//投资金额
@property (nonatomic, assign) NSInteger amount;
//投资期限信息（后期如果存在转让标的，会与loan里面的duration不同）
@property (nonatomic, strong) KSDurationEntity *duration;
//还款方式 1-一次性还款,2-先息后本,4-等额本息,8-等额本金
@property (nonatomic, assign) NSInteger repayMethod;
//投资状态 1 "已申请",2 "已超时",3 "已冻结",4 "资金冻结失败"5 "已取消",6,"已放款"7 "已转让",8 "已还清",9 "已逾期";
@property (nonatomic, assign) NSInteger status;
//投资时间
@property (nonatomic, strong) NSDate *investTime;
//年度投资金额
@property (nonatomic, copy) NSString *annualAmount;
//还款金额
@property (nonatomic, copy) NSString *repayAmount;


//@property (nonatomic, copy) NSString *loanId;
//@property (nonatomic, assign) NSInteger rate;
//@property (nonatomic, copy) NSString *user;
//@property (nonatomic, copy) NSString *assignId;
//@property (nonatomic, copy) NSString *originalAmount;
//@property (nonatomic, copy) NSString *referee;
//@property (nonatomic, copy) NSString *orderId;
//@property (nonatomic, copy) NSString *operaSource;
//@property (nonatomic, assign) BOOL legacy;
//@property (nonatomic, assign) BOOL assignInvest;
//@property (nonatomic, assign) BOOL assigned;
//@property (nonatomic, assign) BOOL loanInvest;
//@property (nonatomic, assign) CGFloat investAmount;





@end
