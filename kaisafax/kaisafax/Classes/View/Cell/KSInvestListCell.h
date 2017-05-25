//
//  KSInvestListCell.h
//  kaisafax
//  理财列表
//  Created by Jjyo on 16/7/12.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSInvestOwnerCell.h"
#import "KSLabel.h"
#import "KSStatusView.h"
#import "MZTimerLabel.h"
#import "UIView+Round.h"

#define kInvestListCell @"KSInvestListCell"


@class KSLoanItemEntity;

@interface KSInvestListCell : KSInvestOwnerCell

@property (weak, nonatomic) IBOutlet UILabel *ruleLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *countdownLabel;

@property (weak, nonatomic) IBOutlet UILabel *newbeeMaxAmount;

@property (weak, nonatomic) IBOutlet UILabel *repayLabel;
@property (weak, nonatomic) IBOutlet KSStatusView *statusView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet MZTimerLabel *timerLabel;
@property (weak, nonatomic) IBOutlet UILabel *buyLabel;


@property (weak, nonatomic) IBOutlet UILabel *topLineView;
@property (weak, nonatomic) IBOutlet UILabel *bottomLineView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;


@property (nonatomic, assign, getter=isNewbee) BOOL newbee;


- (void)setLineHidden:(BOOL)hide;


- (void)updateItem:(KSLoanItemEntity *)entity;
- (void)updateItem:(KSLoanItemEntity *)entity busssiness:(BOOL)b;

@end
