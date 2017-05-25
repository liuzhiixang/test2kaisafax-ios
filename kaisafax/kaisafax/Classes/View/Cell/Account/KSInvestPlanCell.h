//
//  KSInvestPlanCell.h
//  kaisafax
//
//  Created by philipyu on 16/6/30.
//  Copyright © 2016年 com.kaisafax. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kSInvestPlanCell @"KSInvestPlanCell"

@class KSIRItemEntity;
@interface KSInvestPlanCell : UITableViewCell


-(void)updateItem:(KSIRItemEntity *)item; //type:(NSString *)type;
@end
