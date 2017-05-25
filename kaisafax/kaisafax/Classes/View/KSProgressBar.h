//
//  KSProgressBar.h
//  kaisafax
//  投资详情的进度条
//  Created by Jjyo on 16/7/26.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE

@interface KSProgressBar : UIView

/**
 *  文本大小
 */
@property (assign, nonatomic) IBInspectable CGFloat textSize;

/**
 *  文本颜色
 */
@property (strong, nonatomic) IBInspectable UIColor *textColor;

/**
 *  渐变开始颜色
 */
@property (strong, nonatomic) IBInspectable UIColor *gradientStartColor;

/**
 *  渐变结束颜色
 */
@property (strong, nonatomic) IBInspectable UIColor *gradientEndColor;

/**
 *  进度值0~1.0
 */
@property (assign, nonatomic) IBInspectable CGFloat progress;

@end
