//
//  KSInvestHeaderView.m
//  kaisafax
//
//  Created by Jjyo on 16/7/13.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSInvestHeaderView.h"
#import "UIView+Round.h"
#import "KSLabel.h"

@interface KSInvestHeaderView ()

@property (weak, nonatomic) IBOutlet UIStackView *stackView;
@property (weak, nonatomic) IBOutlet UIView *ctView;
@end


@implementation KSInvestHeaderView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)layoutSubviews
{
    [super layoutSubviews];
    [_ctView makeCorners:UIRectCornerTopLeft|UIRectCornerTopRight radius:5.0];
}

- (CGFloat)getPerfectHeightFittingSize:(CGSize)size
{
    
    CGSize s = [_ctView systemLayoutSizeFittingSize:size];
    return s.height;
}


- (void)setTags:(NSArray *)tags
{
    for (UIView *subView in _stackView.arrangedSubviews) {
        [_stackView removeArrangedSubview:subView];
        [subView removeFromSuperview];
    }
    if (tags.count == 0) {
        return;
    }
    _tags = tags;
    NSArray *colors = @[UIColorFromHex(0xf8d66e), UIColorFromHex(0xfe8786)];
    for (int i = 0; i < tags.count; i++) {
        KSLabel *label = [KSLabel new];
        label.text = tags[i];
        label.backgroundColor = colors[i % colors.count];
        label.nuiClass = @"InvestListTagLabel";
        [_stackView addArrangedSubview:label];
    }

}


@end
