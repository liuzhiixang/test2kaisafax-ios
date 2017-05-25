//
//  KSJDCardPayrollRecordCell.h
//  kaisafax
//
//  Created by Jjyo on 2017/3/19.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "KSBaseCell.h"
#import "KSJDExtractItemEntity.h"
#import "KSJDRecordItemEntity.h"

@interface KSJDCardPayrollRecordCell : KSBaseCell

@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *createTimeLabel;


- (void)updateItem:(KSJDRecordItemEntity *)entity;
@end
