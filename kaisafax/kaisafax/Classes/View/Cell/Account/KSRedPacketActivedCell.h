//
//  KSRedPacketActivedCell.h
//  sxfax
//
//  Created by philipyu on 16/2/25.
//  Copyright © 2016年 com.sxfax. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kSRedPacketActivedCell @"KSRedPacketActivedCell"
@class KSRewardItemEntity;
@interface KSRedPacketActivedCell : UITableViewCell
-(void)updateItem:(KSRewardItemEntity*)entity;
@end
