//
//  KSADStartCell.m
//  kaisafax
//
//  Created by semny on 16/9/2.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSADStartCell.h"

@implementation KSADStartCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    //start按钮操作事件
    [_startBtn addTarget:self action:@selector(inner_startAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)inner_startAction:(id)sender
{
    if(_delegate && [_delegate respondsToSelector:@selector(startAction:)])
    {
        [_delegate startAction:self];
    }
}
@end
