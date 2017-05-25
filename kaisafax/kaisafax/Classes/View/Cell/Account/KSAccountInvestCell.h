//
//  KSAccountInvestCell.h
//  kaisafax
//
//  Created by BeiYu on 16/8/16.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kSAccountInvestCell    @"KSAccountInvestCell"
@class KSLoanItemEntity,KSInvestItemEntity,KSUIItemEntity,KSUserInvestsEntity;
@protocol KSAccountInvestCellDelegate <NSObject>

@optional
-(void)accountInvestCellWithLoanID:(KSUIItemEntity*)entity;
@end

@interface KSAccountInvestCell : UITableViewCell

@property (weak, nonatomic) id<KSAccountInvestCellDelegate> delegate;

-(void)updateItem:(KSUIItemEntity*)entity;
@end
