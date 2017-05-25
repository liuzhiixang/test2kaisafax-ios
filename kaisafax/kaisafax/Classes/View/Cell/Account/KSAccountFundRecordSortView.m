//
//  KSAccountFundRecordSortView.m
//  kaisafax
//
//  Created by BeiYu on 16/8/3.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSAccountFundRecordSortView.h"
#import "KSConst.h"
#import "NSDate+Utilities.h"
#import "UIView+Toast.h"

//// 全部
#define TYPE_ALL @"ALL"
//// 充值
#define TYPE_DEPOSIT @"30"
//public static final String TYPE_DEPOSIT = "DEPOSIT";
//// 提现
#define TYPE_WITHDRAW @"20"
//public static final String TYPE_WITHDRAW = "WITHDRAW";
//// 投资
#define TYPE_INVEST  @"10"
//public static final String TYPE_INVEST = "INVEST";
//// 回款
#define TYPE_INVEST_REPAY @"120"
//public static final String TYPE_INVEST_REPAY = "INVEST_REPAY";
//// 还款
#define TYPE_LOAN_REPAY @"50"
//public static final String TYPE_LOAN_REPAY = "LOAN_REPAY";
//// 借款
#define TYPE_LOAN @"40"
//public static final String TYPE_LOAN = "LOAN";
//// 奖励
#define TYPE_TRANSFER @"80"
//public static final String TYPE_TRANSFER = "TRANSFER";

#define kFundRecordsArray   (@[TYPE_ALL,TYPE_DEPOSIT,TYPE_WITHDRAW,@"10,120",@"40,50",TYPE_TRANSFER])
@interface KSAccountFundRecordSortView()
@property (nonatomic,assign) NSInteger typeIndex;
//@property (nonatomic,assign) NSUInteger typeIndex;

@property (weak, nonatomic) IBOutlet UIButton *beginDateBtn;
@property (weak, nonatomic) IBOutlet UIButton *endDateBtn;

- (IBAction)typeBtnClick:(UIButton *)sender;

- (IBAction)dateBtnClick:(UIButton *)sender;

- (IBAction)confirmSortClick:(UIButton *)sender;
@end
@implementation KSAccountFundRecordSortView

-(void)initStatus
{
    for (UIView *subview in self.subviews)
    {
        if ([subview isKindOfClass:[UIButton class]])
        {
            if (subview.tag == KSFundRecordSortAll)
            {
                UIButton *btn = (UIButton *)subview;
                btn.selected = YES;
                btn.backgroundColor = NUI_HELPER.appOrangeColor;
                self.typeIndex = btn.tag;
            }
        }
    }
    
    //初始化时间范围
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    format.dateFormat = @"yyyy.MM.dd";
    NSDate *now = [NSDate date];
    NSTimeInterval interval = [now timeIntervalSince1970];
    //默认起始与截止隔7天
    NSDate *start = [NSDate dateWithTimeIntervalSince1970:interval - 7*24*3600];
    
    [self.beginDateBtn setTitle:[format stringFromDate:start] forState:(UIControlStateNormal)];
    
    [self.endDateBtn setTitle:[format stringFromDate:now] forState:(UIControlStateNormal)];
    
    [self addObserver];

}

- (IBAction)typeBtnClick:(UIButton *)sender
{
#warning 逻辑对？？？
#if 0
    for (UIView *subview in self.subviews)
    {
        if ([subview isKindOfClass:[UIButton class]])
        {
            if ((subview.tag >= KSFundRecordSortAll && subview.tag <= KSFundRecordSortReward)&&
                (subview.tag != sender.tag))
            {
                UIButton *btn = (UIButton *)subview;
                if(btn.selected)
                {
                    btn.selected = NO;
                    btn.backgroundColor = UIColorFromHex(0xebebeb);
                }
            }
        }
    }
    
    sender.selected = !sender.selected;
    sender.backgroundColor =  sender.selected ? NUI_HELPER.appOrangeColor : UIColorFromHex(0xebebeb);
    self.typeIndex = sender.selected?sender.tag:KSFundRecordSortMax;
#endif
  
}

-(void)addObserver
{
 
    [[_allBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        _czBtn.selected = _txBtn.selected = _investBtn.selected = _rewardBtn.selected =_repayBtn.selected =0;
        _allBtn.selected ^= 1;
        _typeIndex = _allBtn.selected?_allBtn.tag:KSFundRecordSortMax;
    }];
    
    [[_czBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        _allBtn.selected = _txBtn.selected = _investBtn.selected = _rewardBtn.selected =_repayBtn.selected =0;
        _czBtn.selected ^= 1;
        _typeIndex = _czBtn.selected?_czBtn.tag:KSFundRecordSortMax;

    }];
    
    [[_txBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        _czBtn.selected = _allBtn.selected  = _investBtn.selected = _rewardBtn.selected =_repayBtn.selected =0;
        _txBtn.selected ^= 1;
        _typeIndex = _txBtn.selected?_txBtn.tag:KSFundRecordSortMax;
    }];
    
    [[_investBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        _czBtn.selected = _txBtn.selected = _allBtn.selected  = _rewardBtn.selected =_repayBtn.selected =0;
        _investBtn.selected ^= 1;
        _typeIndex = _investBtn.selected?_investBtn.tag:KSFundRecordSortMax;
    }];
    
    
    [[_repayBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        _czBtn.selected = _txBtn.selected = _investBtn.selected = _rewardBtn.selected = _allBtn.selected  =0;
        _repayBtn.selected ^= 1;
        _typeIndex = _repayBtn.selected?_repayBtn.tag:KSFundRecordSortMax;
    }];
    
    [[_rewardBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        _czBtn.selected = _txBtn.selected = _investBtn.selected = _allBtn.selected  =_repayBtn.selected =0;
        _rewardBtn.selected ^= 1;
        _typeIndex = _rewardBtn.selected?_rewardBtn.tag:KSFundRecordSortMax;
    }];
}

- (IBAction)dateBtnClick:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(accountFundRecordSortDatePickerWithBtn:)])
    {
        [self.delegate accountFundRecordSortDatePickerWithBtn:sender];
    }
}

- (IBAction)confirmSortClick:(UIButton *)sender
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy.MM.dd"];
    INFO(@"%@ %@",_beginDateBtn.titleLabel.text,_endDateBtn.titleLabel.text);
    NSDate *startDate = [dateFormatter dateFromString:_beginDateBtn.titleLabel.text];
    NSDate *endDate = [dateFormatter dateFromString:_endDateBtn.titleLabel.text];
    
    long long hours = [startDate hour];
    long long distance = hours * 3600 * 1000;
    long long startMs = (long long)[startDate timeIntervalSince1970]*1000 - distance;
    long long endMs = (long long)[endDate timeIntervalSince1970]*1000 + (24 - hours) * 3600 * 1000;
    
    //判断起始日期是否大于截止日期
    if (startMs>=endMs)
    {
        [self makeToast:@"结束日期需要大于起始日期" duration:3.0 position:CSToastPositionCenter];
        return;
    }
    

    //所有的类型都没选中
    if (self.typeIndex == KSFundRecordSortMax)
    {
        [self makeToast:@"请选择要查询的类型" duration:3.0 position:CSToastPositionCenter];
        return;
    }
    
    //ALL 全部、DEPOSIT 充值、WITHDRAW 提现、INVEST/REPAY 投资/回款、REPAY 还款、LOAN/REPAY 借款/还款、TRANSFER 奖励
    NSString *type = TYPE_ALL;
    NSArray *fundArray = kFundRecordsArray;
    if(self.typeIndex >= 1)
        type = fundArray[self.typeIndex-1];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(accountFundRecordSortTimeFrom:To:Type:)])
    {
        [self.delegate accountFundRecordSortTimeFrom:startMs To:endMs Type:type];
    }
}
@end
