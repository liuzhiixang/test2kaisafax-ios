//
//  KSAccountFundRecordCell.h
//  kaisafax
//
//  Created by BeiYu on 16/7/29.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kSAccountFundRecordCell  @"KSAccountFundRecordCell"
@class KSAccountFundRecordModel;



@interface KSAccountFundRecordCell : UITableViewCell
-(void)updateItem:(KSAccountFundRecordModel *)item clearSeprator:(BOOL)isClear;
@end
