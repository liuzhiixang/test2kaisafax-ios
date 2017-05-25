//
//  KSInvestHistoryCell.h
//  kaisafax
//
//  Created by Jjyo on 16/8/1.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kInvestHistoryCell @"KSInvestHistoryCell"
@class KSInvestRecordItemEntity;
@interface KSInvestHistoryCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *investorLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *autoImageView;

- (void)updateItem:(KSInvestRecordItemEntity *)entity;

@end
