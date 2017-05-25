//
//  KSAccountFundRecordSortView.h
//  kaisafax
//
//  Created by BeiYu on 16/8/3.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,KSFundRecordSort)
{
    KSFundRecordSortNone=0,            //默认值
    KSFundRecordSortAll,               //所有
    KSFundRecordSortRecharge,          //充值
    KSFundRecordSortWithdraw,          //提现
    KSFundRecordSortInvestAndReturnMoney,  //投资／回款
    KSFundRecordSortLoanAndRefund,     //借款／还款
    KSFundRecordSortReward,            //奖励
    KSFundRecordSortStartDate,         //开始日期
    KSFundRecordSortEndDate,           //截止日期
    KSFundRecordSortMax,               //最大枚举值
};
@protocol KSAccountFundRecordSortDelegate <NSObject>
@optional
-(void)accountFundRecordSortTimeFrom:(long long)from To:(long long)to Type:(NSString *)type;
-(void)accountFundRecordSortDatePickerWithBtn:(UIButton *)btn;
@end

@interface KSAccountFundRecordSortView : UIView
@property (weak, nonatomic) id<KSAccountFundRecordSortDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton *allBtn;
@property (weak, nonatomic) IBOutlet UIButton *czBtn;
@property (weak, nonatomic) IBOutlet UIButton *txBtn;
@property (weak, nonatomic) IBOutlet UIButton *investBtn;
@property (weak, nonatomic) IBOutlet UIButton *repayBtn;
@property (weak, nonatomic) IBOutlet UIButton *rewardBtn;

-(void)initStatus;
@end
