//
//  SQGestureConfig.h
//  kaisafax
//
//  Created by semny on 16/11/17.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#ifndef SQGestureConfig_h
#define SQGestureConfig_h

#define GES_UIColorFromHexA(hexValue, a)     [UIColor colorWithRed:(((hexValue & 0xFF0000) >> 16))/255.0f green:(((hexValue & 0xFF00) >> 8))/255.0f blue:((hexValue & 0xFF))/255.0f alpha:a]
#define GES_UIColorFromHex(hexValue)        UIColorFromHexA(hexValue, 1.0f)


#define kScreenW [UIScreen mainScreen].bounds.size.width
#define kScreenH [UIScreen mainScreen].bounds.size.height

/**
 *  单个圆背景色
 */
#define CircleBackgroundColor [UIColor clearColor]

/**
 *  普通状态下外空心圆颜色
 */
//#define GestureItemStateNormalOutsideColor rgba(241,241,241,1)
#define GestureItemStateNormalOutsideColor GES_UIColorFromHex(0xa0a0a0)

/**
 *  选中状态下外空心圆颜色
 */
//#define GestureItemStateSelectedOutsideColor rgba(34,178,246,1)
#define GestureItemStateSelectedOutsideColor GES_UIColorFromHex(0xee7700)

/**
 *  错误状态下外空心圆颜色
 */
//#define GestureItemStateErrorOutsideColor rgba(254,82,92,1)
#define GestureItemStateErrorOutsideColor GES_UIColorFromHex(0xe60012)

/**
 *  普通状态下内实心圆颜色
 */
#define GestureItemStateNormalInsideColor [UIColor clearColor]

/**
 *  选中状态下内实心圆颜色
 */
#define GestureItemStateSelectedInsideColor GestureItemStateSelectedOutsideColor

/**
 *  错误状态内实心圆颜色
 */
#define GestureItemStateErrorInsideColor GestureItemStateErrorOutsideColor

/**
 *  普通状态下三角形颜色
 */
#define GestureItemStateNormalTrangleColor [UIColor clearColor]

/**
 *  选中状态下三角形颜色
 */
#define GestureItemStateSelectedTrangleColor GestureItemStateSelectedOutsideColor

/**
 *  错误状态三角形颜色
 */
#define GestureItemStateErrorTrangleColor GestureItemStateErrorOutsideColor

/**
 *  三角形边长
 */
#define kTrangleLength 10.0f

/**
 *  普通时连线颜色
 */
#define CircleConnectLineNormalColor GestureItemStateSelectedOutsideColor

/**
 *  错误时连线颜色
 */
#define CircleConnectLineErrorColor GestureItemStateErrorOutsideColor

/**
 *  连线宽度
 */
#define CircleConnectLineWidth 1.0f

/**
 *  单个圆的半径
 */
#define CircleRadius 35.0f

/**
 *  单个圆的圆心
 */
#define CircleCenter CGPointMake(CircleRadius, CircleRadius)

/**
 *  空心圆圆环宽度
 */
#define CircleEdgeWidth 1.0f

/**
 *  九宫格展示infoView 单个圆的半径
 */
#define CircleInfoRadius 5

/**
 *  内部实心圆占空心圆的比例系数
 */
#define CircleRadio 0.4

/**
 *  整个解锁View居中时，距离屏幕左边和右边的距离
 */
#define CircleViewEdgeMargin 30.0f

/**
 *  整个解锁View的Center.y值 在当前屏幕的3/5位置(默认位置，可手动设置)
 */
#define CircleViewCenterY kScreenH * 3/5

//默认链接的最小数量
#define KMinGestureSelectedItemCount  4
//绘制的手势锁的总数量
#define KCircleWholeItemCountDefault     9

#endif /* SQGestureConfig_h */
