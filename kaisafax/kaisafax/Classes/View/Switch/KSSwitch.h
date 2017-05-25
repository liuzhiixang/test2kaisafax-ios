//
//  KSSwitch.h
//  kaisafax
//
//  Created by semny on 17/1/4.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import <UIKit/UIKit.h>

//手势类型
typedef NS_ENUM(NSInteger, TouchActionType)
{
    TouchActionTypeBegin = 1, //touch begin
    TouchActionTypeMove = 2, //touch move
    TouchActionTypeEnd = 3,   //touch end
    TouchActionTypeCanclled = 4   //touch canclled
};

@interface KSSwitch : UISwitch

//设置touch block
@property (nonatomic, copy) void(^touchBlock)(KSSwitch *tSwitch, NSInteger actionType);

@end
