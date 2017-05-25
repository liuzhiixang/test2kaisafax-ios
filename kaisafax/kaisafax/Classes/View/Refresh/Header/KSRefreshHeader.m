//
//  KSRefreshHeader.m
//  kaisafax
//
//  Created by semny on 16/7/25.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSRefreshHeader.h"

@implementation KSRefreshHeader

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
    
    //顶部隐藏时间
    //self.lastUpdatedTimeLabel.hidden = YES;
    self.lastUpdatedTimeLabel.font = SYSFONT(12.0f);
    self.lastUpdatedTimeLabel.textColor = UIColorFromHex(0xa0a0a0);
    //顶部隐藏状态
    //self.stateLabel.hidden = YES;
    //2x font:24 #a0a0a0
    self.stateLabel.font = SYSFONT(12.0f);
    self.stateLabel.textColor = UIColorFromHex(0xa0a0a0);
}

@end
