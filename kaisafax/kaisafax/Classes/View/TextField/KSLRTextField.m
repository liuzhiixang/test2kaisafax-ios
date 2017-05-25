//
//  KSLRTextField.m
//  kaisafax
//
//  Created by semny on 16/9/22.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSLRTextField.h"

@interface KSLRTextField()

//左边的视图的frame
@property (nonatomic, assign) UIEdgeInsets leftViewRectInsets;

//右边的视图的frame
@property (nonatomic, assign) UIEdgeInsets rightViewRectInsets;

//左边的视图的left
@property (nonatomic, assign) CGFloat leftViewRectInsetsLeft;

//右边的视图的right
@property (nonatomic, assign) CGFloat rightViewRectInsetsRight;

//左边边的视图的right
@property (nonatomic, assign) CGFloat leftViewRectInsetsRight;

@end


@implementation KSLRTextField

- (void)setLeftViewRectInsets:(UIEdgeInsets)rectInsets
{
    _leftViewRectInsets = rectInsets;
}

- (void)setRightViewRectInsets:(UIEdgeInsets)rectInsets
{
    _rightViewRectInsets = rectInsets;
}

//- (void)setLeftViewRectInsetsLeft:(CGFloat)rectInsetsLeft
//{
//    _leftViewRectInsetsLeft = rectInsetsLeft;
//}
//
//- (void)setRightViewRectInsetsRight:(CGFloat)rectInsetsRight
//{
//    _rightViewRectInsetsRight = rectInsetsRight;
//}
//
//- (void)setLeftViewRectInsetsRight:(CGFloat)rectInsetsRight
//{
//    _leftViewRectInsetsRight = rectInsetsRight;
//}

-(CGRect) leftViewRectForBounds:(CGRect)bounds
{
    CGRect iconRect = [super leftViewRectForBounds:bounds];
    //判断左边视图的偏移是否为空
    if (!UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, _leftViewRectInsets))
    {
        //暂时处理了左右间距
        CGFloat left = _leftViewRectInsets.left;
        iconRect.origin.x += left;
    }
    //DEBUGG(@"%s, %@ %@", __FUNCTION__,self, NSStringFromCGRect(iconRect));
    return iconRect;
}

-(CGRect)textRectForBounds:(CGRect)bounds
{
    CGRect textRect = [super textRectForBounds:bounds];
    //DEBUGG(@"%s 111, %@, %@", __FUNCTION__,self, NSStringFromCGRect(textRect));
    //判断左边视图的偏移是否为空
    if (!UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, _leftViewRectInsets))
    {
        //暂时处理了左右间距
        CGFloat right = _leftViewRectInsets.right;
        textRect.origin.x += right;
        //宽度
        textRect.size.width -= right;
    }
    //DEBUGG(@"%s 222, %@, %@", __FUNCTION__,self, NSStringFromCGRect(textRect));
    return textRect;
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds
{
    CGRect iconRect = [super rightViewRectForBounds:bounds];
    //判断右边视图的偏移是否为空
    if (!UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, _rightViewRectInsets))
    {
        //iconRect = UIEdgeInsetsInsetRect(iconRect, _rightViewRectInsets);
        //暂时处理了左右间距
        CGFloat right = _rightViewRectInsets.right;
        iconRect.origin.x -= right;
        CGFloat left = _rightViewRectInsets.left;
        iconRect.size.width += left;
    }
    //DEBUGG(@"%s, %@, %@", __FUNCTION__,self, NSStringFromCGRect(iconRect));
    return iconRect;
}

- (NSString *)description
{
    NSString *temp = [super description];
    
    return [NSString stringWithFormat:@"%@_%@", self.placeholder, temp];
}
@end
