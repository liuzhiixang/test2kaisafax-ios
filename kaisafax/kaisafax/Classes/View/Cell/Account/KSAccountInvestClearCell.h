//
//  KSAccountInvestClearCell.h
//  kaisafax
//
//  Created by BeiYu on 16/8/16.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kSAccountInvestClearCell    @"KSAccountInvestClearCell"
@class KSLoanItemEntity,KSInvestItemEntity,KSUIItemEntity,KSUserInvestsEntity;
@protocol KSAccountInvestClearCellDelegate <NSObject>

@optional
-(void)accountInvestCellWithLoanID:(KSUIItemEntity*)entity;
- (void)showContractFromEntity:(KSUIItemEntity *)entity;
@end

@interface KSAccountInvestClearCell : UITableViewCell

@property (weak, nonatomic) id<KSAccountInvestClearCellDelegate> delegate;

-(void)updateItem:(KSUIItemEntity*)entity;
@end
