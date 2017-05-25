//
//  KSRedPacketGotCell.h
//  sxfax
//
//  Created by philipyu on 16/2/25.
//  Copyright © 2016年 com.sxfax. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kSRedPacketGotCell @"KSRedPacketGotCell"

@class KSRewardItemEntity;
@interface KSRedPacketGotCell : UITableViewCell
-(void)updateItem:(KSRewardItemEntity*)entity;
@end
