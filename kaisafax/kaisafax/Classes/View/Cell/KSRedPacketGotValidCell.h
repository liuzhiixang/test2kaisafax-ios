//
//  KSRedPacketGotView.h
//  kaisafax
//
//  Created by philipyu on 16/8/21.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kSRedPacketGotValidCell  @"KSRedPacketGotValidCell"
@class KSValidRedRewardEntity;
@protocol KSRedPacketGotValidCellDelegate <NSObject>

@optional
- (void)redPacketGotCell:(NSString *)qualified;
@end

@interface KSRedPacketGotValidCell : UITableViewCell

@property (nonatomic,weak) id<KSRedPacketGotValidCellDelegate> delegate;
- (void)updateData:(KSValidRedRewardEntity*)entity;
@end
