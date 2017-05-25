//
//  KSAddBankCardCell.m
//  kaisafax
//
//  Created by semny on 16/12/27.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSAddBankCardCell.h"

@interface KSAddBankCardCell()

@property (weak, nonatomic) IBOutlet UIImageView *addImgView;
@property (weak, nonatomic) IBOutlet UILabel *addTitleLabel;

@end

@implementation KSAddBankCardCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.addTitleLabel.text = KAddBankCardTitle;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)plusBtnClick:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(toPlusBankCards)])
    {
        [self.delegate toPlusBankCards];
    }
}

@end
