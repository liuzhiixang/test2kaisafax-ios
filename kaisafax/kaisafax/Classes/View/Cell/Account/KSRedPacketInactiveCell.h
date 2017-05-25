//
//  KSRedPacketInactiveCell.h
//  sxfax
//
//  Created by philipyu on 16/2/25.
//  Copyright © 2016年 com.sxfax. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kSRedPacketInactiveCell @"KSRedPacketInactiveCell"
@class KSRewardItemEntity;
@interface KSRedPacketInactiveCell : UITableViewCell
-(void)updateItem:(KSRewardItemEntity*)entity;
@end
