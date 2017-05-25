//
//  KSJDCardCell.h
//  kaisafax
//
//  Created by mac on 17/3/17.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KSUIItemEntity.h"

#import "KSInvestOwnerCell.h"

#import "KSJDExtractItemEntity.h"

#define kJDCardListCell @"KSJDCardCell"



@interface KSJDCardCell : KSInvestOwnerCell

@property (weak, nonatomic) IBOutlet UILabel *moneyCardLabel;
@property (weak, nonatomic) IBOutlet UILabel *receiveTimeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *cardStatusImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLineViewLeftLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLineViewRightLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLineViewBottomLayoutConstraint;

//@property (strong, nonatomic) KSJDExtractItemEntity *entity;


- (void)updateItem:(KSJDExtractItemEntity *)entity;

//-(void)updateItem:(KSUIItemEntity *)entity index:(NSInteger)index;

@end
