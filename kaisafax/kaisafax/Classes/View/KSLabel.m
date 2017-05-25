//
//  KSLabel.m
//  kaisafax2
//
//  Created by Jjyo on 16/6/18.
//  Copyright © 2016年 深圳深信金融服务有限公司. All rights reserved.
//

#import "KSLabel.h"
#import "NUIRenderer.h"
#import "NUIAppearance.h"

@interface KSLabel ()
@property (nonatomic, assign) UIEdgeInsets padding;
@end

@implementation KSLabel

- (void)awakeFromNib
{
    [super awakeFromNib];
    if (self.nuiClass) {
        [NUIRenderer renderLabel:self withClass:self.nuiClass];
    }
}


- (void)drawTextInRect:(CGRect)rect
{
    UIEdgeInsets insets = self.padding ;// [NUISettings getEdgeInsets:@"padding" withClass:self.nuiClass];
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

- (CGSize)intrinsicContentSize
{
    UIEdgeInsets insets = self.padding;
    CGSize intrinsicSuperViewContentSize = [super intrinsicContentSize] ;
    intrinsicSuperViewContentSize.height += insets.bottom + insets.top ;
    intrinsicSuperViewContentSize.width += insets.left + insets.right ;
    return intrinsicSuperViewContentSize ;
}


- (UIEdgeInsets)padding
{
    if (self.nuiClass) {
        _padding = [NUISettings getEdgeInsets:@"padding" withClass:self.nuiClass];
        return _padding;
    }
    return UIEdgeInsetsZero;
}


@end
