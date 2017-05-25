//
//  KSRedPacketOverdueCell.h
//  sxfax
//
//  Created by philipyu on 16/2/25.
//  Copyright © 2016年 com.sxfax. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kSRedPacketOverdueCell @"KSRedPacketOverdueCell"


@class KSRewardItemEntity;
@interface KSRedPacketOverdueCell : UITableViewCell
-(void)updateItem:(KSRewardItemEntity*)entity;
@end
