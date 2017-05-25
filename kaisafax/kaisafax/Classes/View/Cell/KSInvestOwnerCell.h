//
//  KSInvestOwnerCell.h
//  kaisafax
//
//  Created by Jjyo on 16/7/13.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSBaseCell.h"
#import "KSOwnerLoanItemEntity.h"
#import "KSLoanItemEntity.h"

#import "KSLabel.h"
#define kInvestOwnerCell @"KSInvestOwnerCell"

@interface KSInvestOwnerCell : KSBaseCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *rateLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet KSLabel *freeLabel;

- (void)updateItem:(KSLoanItemEntity *)entity;
-(void)updateFreeDuration:(KSOwnerLoanItemEntity*)entity;
@end
