//
//  KSAdvertCell.m
//  kaisafax
//
//  Created by Jjyo on 16/7/14.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSAdvertCell.h"
#import "UIView+Round.h"
#import "JKPageView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation KSAdvertCell


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _pageView.pageControlPosition = JKPageControlPositionBottomCenter;
    _pageView.scrollInterval = 5;
    _pageView.endlessScroll = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    [_pageView makeCorners:UIRectCornerAllCorners radius:5.0];
}




@end
