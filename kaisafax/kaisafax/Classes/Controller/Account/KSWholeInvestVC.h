//
//  KSWholeInvestVC.h
//  kaisafax
//
//  Created by philipyu on 16/8/27.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <WMPageController/WMPageController.h>
typedef NS_ENUM(int, WMPageControllerType)
{
    WMPageControllerTypeInvestResult = 0,
    WMPageControllerTypeAccount = 1,

};

@interface KSWholeInvestVC : WMPageController

- (instancetype)initWithIndex:(int)index;
@end
