//
//  KSUnderLineTF.m
//  kaisafax
//
//  Created by semny on 16/8/11.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSUnderLineTF.h"

@implementation KSUnderLineTF

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CALayer *border = [[CALayer alloc] init];
    CGFloat width = 1.0f;
    border.borderColor = [UIColor darkGrayColor].CGColor;
    border.frame = CGRectMake(0.0f, self.frame.size.height-width, self.frame.size.width, self.frame.size.height) ;
    border.borderWidth = width;
    [self.layer addSublayer:border];
    self.layer.masksToBounds = true;
}

@end
