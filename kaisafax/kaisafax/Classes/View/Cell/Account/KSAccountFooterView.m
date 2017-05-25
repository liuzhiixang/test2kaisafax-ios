//
//  KSAccountFooterView.m
//  kaisafax
//
//  Created by BeiYu on 16/7/29.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSAccountFooterView.h"

@interface KSAccountFooterView()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation KSAccountFooterView

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    self.titleLabel.text = KAccountFooterTitle;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}
@end
