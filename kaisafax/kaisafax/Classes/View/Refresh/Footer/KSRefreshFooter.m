//
//  KSRefreshFooter.m
//  kaisafax
//
//  Created by semny on 16/7/25.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSRefreshFooter.h"

@implementation KSRefreshFooter

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
 */

- (void)prepare
{
    [super prepare];
    //样式
    self.stateLabel.font = SYSFONT(12.0f);
    self.stateLabel.textColor = UIColorFromHex(0xa0a0a0);
}



@end
