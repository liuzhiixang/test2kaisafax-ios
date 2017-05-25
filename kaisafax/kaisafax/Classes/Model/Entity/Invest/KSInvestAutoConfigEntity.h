//
//  KSInvestAutoConfigEntity.h
//  kaisafax
//
//  Created by semny on 16/11/23.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"

typedef NS_ENUM(NSUInteger, KSAutoLoanDurationType) {
    KSAutoLoanDurationTypeMonth = 0,
    KSAutoLoanDurationTypeDay = 1,
};


/***
status:<int>,//状态 1-开启,0-关闭
maxDays:<int>,//最大投资时间（时间周期以durType值为准）
minDays:<int>,//最小投资时间（时间周期以durType值为准）
maxRate:<int>,//最大年化利率 *100
minRate:<int>,//最小年化利率 *100
repayMethodIndex:<**int**>,//还款方式（1+2+4+8？）
//BULLET_REPAYMENT(1, "一次性还款"),
//INTEREST(2, "先息后本"),
//EQUAL_INSTALLMENT(4, "等额本息"),
//EQUAL_PRINCIPAL(8, "等额本金");
reservedAmount:<String>,//账户保留金额
minAmount:<int>,//投资最小金额
maxAmount:<int>,//最大投资金额
durType:<int>,//投资周期 0 月 1 天
range:<int>//排名
*/

typedef NS_ENUM(NSUInteger, KSAutoLoanStatus) {
    KSAutoLoanStatusInActive = 0, //关闭
    KSAutoLoanStatusActive = 1,  //开启
};

typedef NS_ENUM(NSUInteger, KSAutoLoanRepayType) {
    KSAutoLoanRepayTypeBullet = 1<<0, //一次性还款
    KSAutoLoanRepayTypeInterest = 1<<1, //先息后本
    KSAutoLoanRepayTypeEqualInstallment = 1<<2, //等额本息
    KSAutoLoanRepayTypeEqualPrincipal = 1<<3, //等额本金
};

@interface KSInvestAutoConfigEntity : KSBaseEntity


//状态 ACTIVE(1,"开启"),INACTIVE(0,"关闭");
//@property (nonatomic, copy) NSString *status;
@property (nonatomic, assign) NSInteger status;
//投资最小金额
@property (nonatomic, assign) long minAmount;
//最大投资金额
@property (nonatomic, assign) long maxAmount;
//最大投资时间(时间周期以durType值为准)
@property (nonatomic, assign) NSInteger maxDays;
//最小投资时间(时间周期以durType值为准)
@property (nonatomic, assign) NSInteger minDays;
//最大年化利率*100
@property (nonatomic, assign) NSInteger maxRate;
//最小年化利率*100
@property (nonatomic, assign) NSInteger minRate;

//还款方式(1+2+4+8?)
@property (nonatomic, assign) NSInteger repayMethodIndex;
//账户保留金额
@property (nonatomic, copy) NSString *reservedAmount;
//投资周期 0 天 1 月
@property (nonatomic, assign) NSInteger durType;
//排名
@property (nonatomic, assign) NSInteger range;

//用户ID
//@property (nonatomic, copy) NSString *userId;
////创建时间
//@property (nonatomic, assign) long long createTime;
////开启时间
//@property (nonatomic, assign) long long activeTime;
//
////是否可用
//@property (nonatomic, assign) BOOL enabled;
//
////最后投资时间
//@property (nonatomic, assign) long long lastInvestedTime;
////更新时间
//@property (nonatomic, assign) long long updateTime;

- (NSString *)getAutoRateText;
- (NSString *)getMinRateText;
- (NSString *)getMaxRateText;
- (NSString *)getAutoDurationText;
- (NSString *)getAutoAmountText;
- (NSString *)getReservedAmountText;
- (NSString *)getAutoDurationType;
- (NSString *)getRangeText;
- (NSArray *)getRepayMethodStringArray;
//是否开启
- (BOOL)isAutoLoanOpen;

//判断还款类型的选择
- (BOOL)isEQUAL_PRINCIPAL;
- (BOOL)isEQUAL_INSTALLMENT;
- (BOOL)isBULLET_REPAYMENT;
- (BOOL)isINTEREST;

@end
