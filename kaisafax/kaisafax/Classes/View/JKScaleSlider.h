//
//  JKScaleSlider.h
//  HelloWorld
//
//  Created by Jjyo on 16/7/17.
//  Copyright © 2016年 Jjyo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JKScaleSlider;
@protocol JKScaleSliderDelegate <NSObject>
@optional
/**
 *  返回指定值下的文本标志,
 *
 *  @param slider 调用对象
 *  @param value  当前刻度值
 *
 *  @return 当string不为nil显示, nil则不显示
 */
- (NSString *)scaleSlider:(JKScaleSlider *)slider titleAtValue:(NSInteger)value;

/**
 *  刻度尺滚动值的改变
 *
 *  @param slider 调用对象
 *  @param value  当前的刻度值
 */
- (void)scaleSlider:(JKScaleSlider *)slider didChangeValue:(NSInteger)value;
@end


IB_DESIGNABLE

@interface JKScaleSlider : UIView

@property (nonatomic, weak) IBOutlet id<JKScaleSliderDelegate> delegate;

@property (nonatomic, assign) IBInspectable NSInteger textSize; //文字大小
@property (nonatomic, strong) IBInspectable UIColor *textColor; //文字颜色

@property (nonatomic, strong) IBInspectable UIColor *centerLineColor; //中间线的颜色
@property (nonatomic, strong) IBInspectable UIColor *lineColor; //线的颜色
@property (nonatomic, assign) IBInspectable NSInteger lineSpan;// 线的间距
@property (nonatomic, assign) IBInspectable NSInteger lineMaxHeight;//线的最大高度
@property (nonatomic, assign) IBInspectable NSInteger lineMinHeight;//线的最小高度


@property (nonatomic, assign) IBInspectable NSInteger minValue; //最小值
@property (nonatomic, assign) IBInspectable NSInteger maxValue; //最大值
@property (nonatomic, assign) IBInspectable NSInteger stepValue;    //步进

@property (nonatomic, assign) NSInteger value;

- (void)setValue:(NSInteger)value callback:(BOOL)call;

@end
