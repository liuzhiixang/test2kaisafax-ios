//
//  KSFastCardCell.m
//  kaisafax
//
//  Created by Jjyo on 16/8/10.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSFastCardCell.h"
#import "UIView+Round.h"
#import "KSCardItemEntity.h"
#import "KSBankEntity.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface KSFastCardCell ()
@property (weak, nonatomic) IBOutlet UIView *cardView;
@property (weak, nonatomic) IBOutlet UIView *userView;
@property (weak, nonatomic) IBOutlet UIView *cardStopView;

@property (weak, nonatomic) IBOutlet UILabel *cardNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *cardDetailLabel;
@property (weak, nonatomic) IBOutlet UIImageView *cardIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *bankLabel;
@end


@implementation KSFastCardCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
}

- (void)updateItem:(KSCardItemEntity *)entity bank:(KSBankEntity *)bank
{
    
    _cardNameLabel.text = bank.name;
    _nameLabel.text = entity.name;
    _bankLabel.text = [entity formatAccount];
    _cardDetailLabel.text = [bank getDetailText];
    UIImage *image = [UIImage imageNamed:@"ic_bank_fast"];
    [_cardIconImageView sd_setImageWithURL:[NSURL URLWithString:bank.bankIconUrl] placeholderImage:image];
}

- (void)setCardDisable:(BOOL)disable
{
    _rechargeButton.enabled = !disable;
    _cardStopView.hidden = !disable;
}

@end
