//
//  KSPromoteCell.h
//  kaisafax
//
//  Created by Jjyo on 16/8/1.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSInviteUserEntity.h"

#define kPromoteCell @"KSPromoteCell"

@interface KSPromoteCell : UITableViewCell

- (void)updateItem:(KSInviteUserEntity *)entity;

@end
