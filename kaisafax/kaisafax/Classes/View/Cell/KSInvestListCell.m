//
//  KSInvestListCell.m
//  kaisafax
//
//  Created by Jjyo on 16/7/12.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSInvestListCell.h"


@interface KSInvestListCell ()<MZTimerLabelDelegate>
{
    CGFloat _bottomViewHeight;
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomHeight;

@property (weak, nonatomic) IBOutlet UIStackView *stackView;

@property (weak, nonatomic) KSLoanItemEntity *entity;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLineViewLeftLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLineViewRightLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLineViewBottomLayoutConstraint;
@end

@implementation KSInvestListCell


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    _timerLabel.timerType = MZTimerLabelTypeTimer;
    _bottomViewHeight = _bottomHeight.constant;
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [_buyLabel makeRoundCorner];
    
    if (!self.backgroundImageView.hidden) {
        
        CGRect frame =  CGRectZero;
        frame.origin.x = self.margins.top;
        frame.origin.y = self.margins.left;
        frame.size.width = CGRectGetHeight(self.frame) - self.margins.top - self.margins.bottom;
        frame.size.height = CGRectGetWidth(self.frame) - self.margins.left - self.margins.right;
        
        self.backgroundImageView.frame = frame;
    }

}

- (void)setNewbee:(BOOL)newbee
{
    _newbee = newbee;
    if (newbee) {
        _bottomHeight.constant = 4;
        _bottomView.hidden = YES;
    }
    else{
        _bottomHeight.constant = _bottomViewHeight;
        _bottomView.hidden = NO;
    }
}




- (void)setLineHidden:(BOOL)hide
{
    _topLineView.hidden = hide;
    _bottomLineView.hidden = hide;
}

- (void)updateItem:(KSLoanItemEntity *)entity
{
    
    [self updateItem:entity busssiness:NO ];
}

- (void)updateItem:(KSLoanItemEntity *)entity busssiness:(BOOL)b
{
    [super updateItem:entity];
    
    DEBUGG(@"333 %s, loan: %@", __FUNCTION__, entity);
    NSMutableArray *tags = [NSMutableArray array];
    _entity = entity;
    if (b) {
        [self setNewbee:b];
        [self setLineHidden:YES];
    }

    if (entity.loanProduct == 0)
    {
        [tags addObject:@"NEWBEE"];
    }
    else
    {
        if (entity.additionalRate > 0) {
            [tags addObject:@"RATE"];
        }
        if (entity.advanceRepayAble) {
            [tags addObject:@"ABLE"];
        }
        NSString *recommed = [entity getRecommendKey];
        if (recommed) {
            [tags addObject:recommed];
        }
    }
    [self setTags:tags];
    _repayLabel.text = [entity getRepayMethodText];
    _leftAmountLabel.text = [entity getLeftAmountText];
    _ruleLabel.text = [entity getRuleText];
    
    
    _buyLabel.hidden = ![entity isNewBee];
    _newbeeMaxAmount.hidden = ![entity isNewBee];
    
    long countdownTime = [entity getCountdownTime];
    if (countdownTime > 0) {
        _statusView.statusStyle = KSStatusStyleNormal;
        _timerLabel.delegate = self;
        [_timerLabel setCountDownTime:countdownTime/1000];
        [_timerLabel start];
    }else{
        BOOL loanOpen = [entity isLoanOpen];
        _statusView.statusStyle = (loanOpen ? KSStatusStyleProgress : KSStatusStyleStatus);
        _statusView.statusText = [entity getStatusText];
        _statusView.progress = [entity getProgress];
        _statusView.progressText = [entity getStatusText];
        _statusView.disable = !loanOpen;
    }
    
    _statusView.hidden = [entity isNewBee];
    
    _timerLabel.hidden = (countdownTime == 0);
    _countdownLabel.hidden = _timerLabel.hidden;
    
    if (!self.backgroundImageView.hidden)
    {
        
        self.topLineView.hidden = NO;
        _topLineViewLeftLayoutConstraint.constant = 16;
        _topLineViewRightLayoutConstraint.constant = 16;
        _topLineViewBottomLayoutConstraint.constant = 2;
        
        _bottomHeight.constant = 12;

    }
    
    DEBUGG(@"555 %s, loan: %@", __FUNCTION__, entity);
    [self.contentView updateConstraints];
    [self.contentView layoutIfNeeded];
}


- (void)setTags:(NSMutableArray*)tags
{
    for (UIView *subView in _stackView.arrangedSubviews) {
        [_stackView removeArrangedSubview:subView];
        [subView removeFromSuperview];
    }
    if (tags == nil) {
        return;
    }
    for (NSString *tag in tags) {
        KSLabel *label = [KSLabel new];
        if([tag isEqualToString:@"RATE"])
            label.text = @"已加息";
        else if([tag isEqualToString:@"ABLE"])
            label.text = @"可提前还款";
        else if([tag isEqualToString:@"NEWBEE"])
            label.text = @"新手";
        else
            label.text = [_entity getRecommendTag];
        label.nuiClass = @"InvestListTagLabel";
        [_stackView addArrangedSubview:label];
        if([NUISettings hasProperty:tag withClass:label.nuiClass])
        {
            label.backgroundColor = [NUISettings getColor:tag withClass:label.nuiClass];
        }
    }
}
#pragma mark - MZTimerLabelDelegate

-(void)timerLabel:(MZTimerLabel*)timerLabel finshedCountDownTimerWithTime:(NSTimeInterval)countTime
{
    _entity.status = @"OPEN";
    [self updateItem:_entity];
    
}

-(NSString*)timerLabel:(MZTimerLabel*)timerLabel customTextToDisplayAtTime:(NSTimeInterval)time
{
    int second = (int)time  % 60;
    int minute = ((int)time / 60) % 60;
    int hours = time / 3600;
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours,minute,second];
}

@end
