//
//  KSCardCell.m
//  kaisafax
//
//  Created by Jjyo on 16/8/10.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSCardCell.h"

@implementation KSCardCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _payCheckBox.hidden = YES;
    self.backgroundView = [UIView  new];
    self.backgroundView.backgroundColor = WhiteColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
