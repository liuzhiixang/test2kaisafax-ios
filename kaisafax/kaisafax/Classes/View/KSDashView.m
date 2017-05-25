//
//  KSDashView.m
//  kaisafax
//
//  Created by philipyu on 16/8/30.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSDashView.h"
#import "KSConst.h"



@implementation KSDashView


- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    CAShapeLayer *border = [CAShapeLayer layer];
    
    border.strokeColor = UIColorFromHex(0xC5C5C5).CGColor;
    
    border.fillColor = WhiteColor.CGColor;
    
    border.path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:5.0].CGPath;
    
    border.frame = self.bounds;
    
    border.lineWidth = 1.f;
    
    border.lineCap = @"square";
    
    border.lineDashPattern = @[@4, @2];
    
    
    
    [self.layer addSublayer:border];
    
}


@end
