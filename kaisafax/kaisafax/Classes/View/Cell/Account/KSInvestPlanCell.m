//
//  KSInvestPlanCell.m
//  kaisafax
//
//  Created by philipyu on 16/6/30.
//  Copyright © 2016年 com.kaisafax. All rights reserved.
//

#import "KSInvestPlanCell.h"
#import "KSInvestRepayEntity.h"
#import "KSIRItemEntity.h"


@interface KSInvestPlanCell()
@property (weak, nonatomic) IBOutlet UIButton *periodBtn;
@property (weak, nonatomic) IBOutlet UILabel *profitLabel;
@property (weak, nonatomic) IBOutlet UILabel *benjinLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *wuyeLabel;
@property (weak, nonatomic) IBOutlet UILabel *wuyeTips;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *periodBtnWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *periodLabel;

@end

@implementation KSInvestPlanCell


-(void)updateItem:(KSIRItemEntity *)item //type:(NSString *)type
{
//    _item = item;
//    self.periodLabel.text = [NSString stringWithFormat:@"第 %d 期",item.period ];
    NSString *periodStr = [NSString stringWithFormat:@"%ld",item.period ];
//    NSInteger periodLen = [item.period length];
    if (item.period  >= 10)
    {
        self.periodBtnWidthConstraint.constant = 25.0;
        [self.periodBtn setBackgroundImage:[UIImage imageNamed:@"ic_plan_2"] forState:(UIControlStateNormal)];
    }
    else
    {
        self.periodBtnWidthConstraint.constant = 14.0;
        [self.periodBtn setBackgroundImage:[UIImage imageNamed:@"ic_plan_1"] forState:(UIControlStateNormal)];
    }
//    [self.periodBtn setTitle:periodStr  forState:(UIControlStateNormal)];

    self.periodLabel.text = periodStr;
    
    self.profitLabel.text = item.repayProfit; //[NSString stringWithFormat:@"%.2f",item.repayProfit ];
    self.benjinLabel.text = item.repayPrincipal; //[NSString stringWithFormat:@"%.2f",item.repayPrincipal];
    self.statusLabel.text = item.getStatusText;
    self.dateLabel.text = [NSString stringWithFormat:@"%ld/%ld/%ld",(long)item.dueDate.year,(long)item.dueDate.monthValue,(long)item.dueDate.dayOfMonth];
    
    BOOL isOwner = item.isOwner;
    if (isOwner)
    {
        self.wuyeLabel.text = item.ownerFee;//[NSString stringWithFormat:@"%.2f",(CGFloat)item.ownerFee];
        self.wuyeLabel.hidden = NO;
        self.wuyeTips.hidden = NO;
    }
    else
    {
        self.wuyeLabel.hidden = YES;
        self.wuyeTips.hidden = YES;
    }
}


@end
