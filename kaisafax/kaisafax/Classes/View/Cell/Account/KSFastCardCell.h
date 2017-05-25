//
//  KSFastCardCell.h
//  kaisafax
//
//  Created by Jjyo on 16/8/10.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kFastCardCell @"KSFastCardCell"

@class KSCardItemEntity;
@class KSBankEntity;
@interface KSFastCardCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIButton *unbindButton;
@property (nonatomic, weak) IBOutlet UIButton *rechargeButton;

- (void)updateItem:(KSCardItemEntity *)entity bank:(KSBankEntity *)bank;
- (void)setCardDisable:(BOOL)disable;
@end
