//
//  KSLoanItemEntity.h
//  kaisafax
//
//  Created by semny on 16/8/1.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseEntity.h"
#import "KSDurationEntity.h"
#import "KSRealmEntity.h"
#import "KSRulesEntity.h"

#define REPAY_METHOD @[ \
	@"一次性还款",      \
	@"先息后本",        \
	@"等额本息",        \
	@"等额本金",        \
]

/**
 *  @author semny
 *
 *  标的信息(基础信息，单条)
 */
@interface KSLoanItemEntity : KSBaseEntity

//投资次数
@property (nonatomic, assign) NSInteger investCount;
//剩余标的金额
@property (nonatomic, assign) NSInteger leftAmount;
//开标时间
@property (nonatomic, assign) long long openTime;

//@property (nonatomic, assign, getter=isNewbee) BOOL newbee;
//借款人员
@property (nonatomic, copy) NSString *userId;
//结束时间
@property (nonatomic, strong) NSDate *finishTime;
//允许自动投标最大投资次数
@property (nonatomic, assign) NSInteger maxAutoInvestPercetage;
//运营标签： 0 无运营标签、1 尊享、2 ("推荐"/"热门")、3 银行承兑、4 资信等级A、5 资信等级AA、6 资信等级AAA
@property (nonatomic, assign) NSInteger recommendLabel;
//标的状态 7 筹款中,9 已满标,10 放款中,11 还款中,12 已还清,13 已逾期
@property (nonatomic, assign) NSInteger status;
//优惠折扣信息
@property (nonatomic, assign) NSInteger discount;
//标的合同ID
@property (nonatomic, copy) NSString *contract;
//投资期限 期限的算法见接口（标的信息）
@property (nonatomic, strong) KSDurationEntity *duration;
//筹款时长
@property (nonatomic, assign) NSInteger timeOut;
//加息数值(判断是否大于0)
@property (nonatomic, assign) NSInteger additionalRate;
//服务器时间
@property (nonatomic, assign) long long serverTime;
//标的投资规则
@property (nonatomic, strong) KSRulesEntity *investRule;

/*************我的投资列表中用到0425******************/
//标的id
@property (nonatomic, assign) long long ID;
//还清时间
@property (nonatomic, strong) NSDate *clearTime;
//标的金额
@property (nonatomic, assign) NSInteger amount;
//标的标题
@property (nonatomic, copy) NSString *title;
//标的年化利率
@property (nonatomic, assign) NSInteger rate;
//还款方式 1-一次性还款,2-先息后本,4-等额本息,8-等额本金
@property (nonatomic, assign) NSInteger repayMethod;
//提前还款标志 是否允许提前结清  true-是，false-否
@property (nonatomic, assign) BOOL advanceRepayAble;
//投资金额
@property (nonatomic, assign) NSInteger investAmount;
//标的产品类型 0 新手标。 999 普通标
@property (nonatomic, assign) NSInteger loanProduct;

//期限
- (NSString *)getDurationText;
//免费的期限
//- (NSString *)getFreeText;
//年化率
- (NSString *)getRateText;
//起投金额
- (NSString *)getInvestMinAmount;
//带单位的
- (NSString *)getInvestMinAmountWithUnit:(NSString *)unit;
//还款方式
- (NSString *)getRepayMethodText;
//标的的进度：结果小于1%，显示1%；结果大于99%小于100%，显示99%
- (CGFloat)getProgress;
//获取倒计时
- (long)getCountdownTime;
//根据服务器时间计算本地倒计时
- (void)calcCountdownTime;

- (NSString *)getStatusText;

- (BOOL)isLoanOpen;

- (NSString *)getRuleText;

- (NSString *)getLeftAmountText;
//计算收益
- (NSString *)getRevenueFromAmount:(CGFloat)amount;

/**
 *  全额投
 1. 用户的可用余额 < 标的最小投资金额，全额投金额＝0de；
 2. 全额投金额 不能 大于  标的剩余金额；
 3. 全额投金额 不能大于 标的最大投资金额
 4. 全额投金额 不能小于 标的最小投资金额
 5. 全额投金额必须符合 标的递增金额
 *
 *  @param available 用户可用金额
 *
 *  @return 全额投的金额
 */
- (NSUInteger)getCanInvestMaxInAvailable:(NSUInteger)available;

- (NSString *)getRecommendTag;
- (NSString *)getRecommendKey;

- (NSString *)getTextFormRecommendTag:(NSInteger)tag;
- (BOOL)isNewBee;
@end
