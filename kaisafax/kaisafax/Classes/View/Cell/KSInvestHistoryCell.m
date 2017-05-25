//
//  KSInvestHistoryCell.m
//  kaisafax
//
//  Created by Jjyo on 16/8/1.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSInvestHistoryCell.h"
#import "NSDate+Utilities.h"
#import "KSInvestRecordItemEntity.h"
@implementation KSInvestHistoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)updateItem:(KSInvestRecordItemEntity *)entity
{
    _investorLabel.text = entity.investor;
    _amountLabel.text = [KSBaseEntity formatAmountString:entity.amount withUnit:@"元"];
    _timeLabel.text =  [entity.investTime dateStringWithFormat:@"yyyy/MM/dd HH:mm:ss"];
    _autoImageView.hidden = !entity.isAutoInvest;
}

@end
