//
//  KSLineChartView.h
//  kaisafax
//
//  Created by Jjyo on 16/7/22.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KSLineChartView : UIView

@property (assign, nonatomic) UIEdgeInsets padding;

/**
 *  文本大小
 */
@property (assign, nonatomic) NSUInteger textSize;

/**
 *  文本颜色
 */
@property (strong, nonatomic) UIColor *textColor;

/**
 *  Y轴的网格线颜色
 */
@property (strong, nonatomic) UIColor *yGridColor;

/**
 *  曲线颜色
 */
@property (strong, nonatomic) UIColor *lineColor;

/**
 *  线的宽线
 */
@property (assign, nonatomic) NSUInteger lineWidth;

/**
 *  Y 轴最大值
 */
@property (assign, nonatomic) CGFloat yMaxValue;

/**
 *  Y 轴最小值
 */
@property (assign, nonatomic) CGFloat yMinValue;

/**
 *  Y 轴与标签文本的间距
 */
@property (assign, nonatomic) CGFloat yLabelAxisSpan;

/**
 *  X 轴与标签文本的间距
 */
@property (assign, nonatomic) CGFloat xLabelAxisSpan;

/**
 *  X 轴文本标签数组
 */
@property (copy, nonatomic) NSArray *xLabels;

/**
 *  Y 轴文本标签数组
 */
@property (copy, nonatomic) NSArray *yLabels;

/**
 *  数据组
 */
@property (copy, nonatomic) NSArray *lineDatas;


/**
 *  是否显示平滑的连接线
 */
@property (assign, nonatomic) BOOL showSmoothLines;

/**
 *  显示动画
 */
@property (assign, nonatomic) BOOL displayAnimated;

@end
