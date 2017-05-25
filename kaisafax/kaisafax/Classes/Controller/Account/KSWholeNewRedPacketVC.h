//
//  KSWholeNewRedPacketVC.h
//  kaisafax
//
//  Created by BeiYu on 2017/4/12.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import <WMPageController/WMPageController.h>

#pragma mark -
#pragma mark the navgation button type
//#define kRPNavLeftButtonTag 1
//#define kRPNavRightButtonTag 2

#pragma mark -
#pragma mark the navgation title show style
#define kNavTitleImageStyle 1
#define kNavTitleTextStyle 2

#pragma mark -
#pragma mark the navgation button size
#define kNavButtonWidth 75
#define kNavButtonHeight 25

//VC所有标题的字体样式
#define WholeVCTitleFont            SYSFONT(15.0f)
//页面背景色
#define WholeVCColorBg             UIColorFromHex(0xEBEBEB)


@interface KSWholeNewRedPacketVC : WMPageController
@property (nonatomic,assign) KSWebSourceType type;

@end
