//
//  KSInvestOwnerCell.m
//  kaisafax
//
//  Created by Jjyo on 16/7/13.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSInvestOwnerCell.h"


@interface KSInvestOwnerCell ()


@end


@implementation KSInvestOwnerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.backgroundView = [UIView  new];
    self.backgroundView.backgroundColor = [UIColor whiteColor];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)updateItem:(KSLoanItemEntity *)entity
{
    DEBUGG(@"111 %s, loan: %@", __FUNCTION__, entity);
    _titleLabel.text = entity.title;
    _rateLabel.text = [KSBaseEntity formatAmount:entity.rate / 100.];
    _durationLabel.text = [entity getDurationText];
//    _freeLabel.text = [entity getFreeText];
    DEBUGG(@"222 %s, loan: %@", __FUNCTION__, entity);
}

-(void)updateFreeDuration:(KSOwnerLoanItemEntity*)entity
{
    _freeLabel.text = [entity getFreeText];
}

@end
