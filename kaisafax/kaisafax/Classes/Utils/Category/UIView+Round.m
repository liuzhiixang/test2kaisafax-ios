//
//  UIView+Round.m
//  kaisafax
//
//  Created by Jjyo on 16/7/11.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "UIView+Round.h"

@implementation UIView (Round)

- (void)makeCorners:(UIRectCorner)corners radius:(CGFloat)radius
{
    if (corners == UIRectCornerAllCorners) {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = radius;
    }else{
        UIBezierPath *maskPath;
        maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                         byRoundingCorners:corners
                                               cornerRadii:CGSizeMake(radius, radius)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.bounds;
        maskLayer.path = maskPath.CGPath;
        self.layer.mask = maskLayer;
    }
}

- (void)makeRoundCorner
{
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = (width + height) / 4;
}

- (void)makeRoundedCornerWithRradius:(CGFloat)radius borderWidth:(CGFloat)borderWidth backgroundColor:(UIColor*)backgroundColor borderColor:(UIColor*)borderColor
{
//    CGSize size = CGSizeZero;//sizeToFit
//    UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.mainScreen.scale)
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    CGContextMoveToPoint(context, 开始位置);  // 开始坐标右边开始
//    CGContextAddArcToPoint(context, x1, y1, x2, y2, radius);  // 这种类型的代码重复四次
//    
//    CGContextDrawPath(UIGraphicsGetCurrentContext(), .FillStroke)
//    UIImage *output = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
}
@end
