//
//  NUIHelper.h
//  kaisafax
//  
//  Created by Jjyo on 16/9/23.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <Foundation/Foundation.h>
//NUI
#import "NUIRenderer.h"
#import "NUIAppearance.h"
#import "NUIRenderer+Additions.h"
#define NUI_HELPER [NUIHelper shareInstance]

//=============== 全局样式 ==============

#define NUIAppSmallOrangeLabel @"AppSmallOrangeLabel"
#define NUIAppNormalOrangeLabel @"AppNormalOrangeLabel"
#define NUIAppXXSmallDarkGrayLabel @"AppXXSmallDarkGrayLabel"
#define NUIAppXSmallDarkGrayLabel @"AppXSmallDarkGrayLabel"
#define NUIAppSmallDarkGrayLabel @"AppSmallDarkGrayLabel"
#define NUIAppNormalDarkGrayLabel @"AppNormalDarkGrayLabel"
#define NUIAppLargeDarkGrayLabel @"AppLargeDarkGrayLabel"
#define NUIAppCellLargeLightGrayLabel @"AppCellLargeLightGrayLabel"
#define NUIAppCellLightRedLabel @"AppCellLightRedLabel"
#define NUIAppJDLightRedLabel @"AppJDLightRedLabel"
#define NUIAppLargeBuleLabel @"AppLargeBuleLabel"
#define NUIAppXLargerDarkGrayLabel @"AppXLargerDarkGrayLabel"
#define NUIAppXXLargerDarkGrayLabel @"AppXXLargerDarkGrayLabel"
#define NUIAppXXSmallLightGrayLabel @"AppXXSmallLightGrayLabel"
#define NUIAppXSmallLightGrayLabel @"AppXSmallLightGrayLabel"
#define NUIAppSmallLightGrayLabel @"AppSmallLightGrayLabel"
#define NUIAppNormalLightGrayLabel @"AppNormalLightGrayLabel"
#define NUIAppLargeLightGrayLabel @"AppLargeLightGrayLabel"
#define NUIAppXLargerLightGrayLabel @"AppXLargerLightGrayLabel"
#define NUIAppXXLargerLightGrayLabel @"AppXXLargerLightGrayLabel"
#define NUIAppLargeWhiteLabel @"AppLargeWhiteLabel"
#define NUINavigationBar @"NavigationBar"
#define NUIAppBackgroundView @"AppBackgroundView"
#define NUIAppBackgroundRoundView @"AppBackgroundRoundView"
#define NUIAppRoundView @"AppRoundView"
#define NUIAppBlackView @"AppBlackView"
#define NUIAppTextField @"AppTextField"
#define NUIAppOrangeButton @"AppOrangeButton"
#define NUIAppGrayButton @"AppGrayButton"


//========= Tabbar ==========



@interface NUIHelper : NSObject


/**
 *  浅灰色文本颜色
 */
@property (nonatomic, strong, readonly) UIColor *appLightGrayColor;
/**
 *  深灰色文本颜色
 */
@property (nonatomic, strong, readonly) UIColor *appDarkGrayColor;
/**
 *  边框颜色
 */
@property (nonatomic, strong, readonly) UIColor *appBorderColor;
/**
 *  默认背景颜色
 */
@property (nonatomic, strong, readonly) UIColor *appBackgroundColor;
/**
 *  主题橙色
 */
@property (nonatomic, strong, readonly) UIColor *appOrangeColor;
/**
 *  标题栏颜色
 */
@property (nonatomic, strong, readonly) UIColor *appNavigationBarTintColor;
/**
 *  失效颜色
 */
@property (nonatomic, strong, readonly) UIColor *appDisableColor;

/**
 *  8号字体
 */
@property (nonatomic, assign, readonly) CGFloat appXXSmallFontSize;
/**
 *  10号字体
 */
@property (nonatomic, assign, readonly) CGFloat appXSmallFontSize;
/**
 *  12号字体
 */
@property (nonatomic, assign, readonly) CGFloat appSmallFontSize;
/**
 *  14号字体
 */
@property (nonatomic, assign, readonly) CGFloat appNormalFontSize;
/**
 *  16号字体
 */
@property (nonatomic, assign, readonly) CGFloat appLargeFontSize;
/**
 *  18号字体
 */
@property (nonatomic, assign, readonly) CGFloat appXLargerFontSize;
/**
 *  20号字体
 */
@property (nonatomic, assign, readonly) CGFloat appXXLargerFontSize;

/**
 *  圆角半径
 */
@property (nonatomic, assign, readonly) CGFloat appCornerRadius;


+ (instancetype)shareInstance;

@end
