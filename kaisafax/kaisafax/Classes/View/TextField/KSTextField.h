//
//  KSTextField.h
//  kaisafax
//
//  Created by Jjyo on 16/9/7.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <UIKit/UIKit.h>

//只是给金额输入相关的使用
@interface KSTextField : UITextField <UITextFieldDelegate>
@property (nonatomic, assign) NSInteger maxLength;
@property (nonatomic, assign) CGFloat maxValue;

/**
 *  @author semny
 *
 *  设置placeholder的文字颜色
 *
 *  @param textColor 颜色
 */
- (void)setPlaceholderTextColor:(UIColor *)textColor;

/**
 *  @author semny
 *
 *  设置placeholder的文字字体
 *
 *  @param textFont 字体
 */
- (void)setPlaceholderTextFont:(UIFont *)textFont;

/**
 *  @author semny
 *
 *  设置placeholder是否隐藏
 *
 *  @param hidden YES:隐藏，NO:显示
 */
- (void)setPlaceholderHidden:(BOOL)hidden;

@end
