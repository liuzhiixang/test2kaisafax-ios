//
//  KSNewbeeCell.m
//  kaisafax
//
//  Created by Jjyo on 16/7/13.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSNewbeeCell.h"
#import "MZTimerLabel.h"
#import "KSRulesEntity.h"

@interface KSNewbeeCell() <MZTimerLabelDelegate>
{
    KSNewbeeEntity *_entity;
}

@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *rateLabel;
@property (weak, nonatomic) IBOutlet UILabel *minAmoutLabel;
@property (weak, nonatomic) IBOutlet MZTimerLabel *timerLabel;

@end


@implementation KSNewbeeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.backgroundView = [UIView  new];
    self.backgroundView.backgroundColor = [UIColor whiteColor];
    _timerLabel.textColor = NUI_HELPER.appOrangeColor;
    _timerLabel.timerType = MZTimerLabelTypeTimer;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateItem:(KSNewbeeEntity *)entity
{
    //INFO(@"update item:%@", entity);
    _entity = entity;
    _durationLabel.text = [entity.loan getDurationText];
    _rateLabel.text = [KSBaseEntity formatAmount:entity.loan.rate / 100.];
    _minAmoutLabel.text = [NSString stringWithFormat:@"%ld元", entity.loan.investRule.minAmount];
//    _investButton.enabled = [entity.loanData isLoanOpen];
    
    long countdownTime = [entity.loan getCountdownTime];
    if (countdownTime > 0) {
        _investButton.enabled = NO;
        [_investButton setTitle:@"" forState:UIControlStateDisabled];
        _timerLabel.hidden = NO;
        _timerLabel.delegate = self;
        [_timerLabel setCountDownTime:countdownTime/1000];
        [_timerLabel start];
    }else{
        _investButton.enabled = YES ;
        _timerLabel.hidden = YES;
        _timerLabel.delegate = nil;
    }
}

#pragma mark - MZTimerLabelDelegate

-(void)timerLabel:(MZTimerLabel*)timerLabel finshedCountDownTimerWithTime:(NSTimeInterval)countTime
{
    _entity.loan.status = 0;
    [self updateItem:_entity];
}

-(NSString*)timerLabel:(MZTimerLabel*)timerLabel customTextToDisplayAtTime:(NSTimeInterval)time
{
    int second = (int)time  % 60;
    int minute = ((int)time / 60) % 60;
    int hours = time / 3600;
    return [NSString stringWithFormat:@"抢标倒计时  %02d:%02d:%02d",hours,minute,second];
}

@end
