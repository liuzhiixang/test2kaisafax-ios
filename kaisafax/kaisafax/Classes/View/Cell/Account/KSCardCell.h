//
//  KSCardCell.h
//  kaisafax
//
//  Created by Jjyo on 16/8/10.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import  "KSBaseCell.h"
#import "BEMCheckBox.h"
#define kCardCell @"KSCardCell"

@interface KSCardCell : KSBaseCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet BEMCheckBox *payCheckBox;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@end
