//
//  KSJDCardPayrollRecordCell.m
//  kaisafax
//
//  Created by Jjyo on 2017/3/19.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSJDCardPayrollRecordCell.h"
#import "NSDate+Utilities.h"



@implementation KSJDCardPayrollRecordCell

- (void)updateItem:(KSJDRecordItemEntity *)entity
{
    _amountLabel.text = [NSString stringWithFormat:@"%@元", entity.amount];
    _titleLabel.text = entity.remarkOut;
    _createTimeLabel.text = [NSString stringWithFormat:@"发放时间: %@", [entity.createTime dateStringWithFormat:@"yyyy-MM-dd HH:mm:ss"]];
}

@end
