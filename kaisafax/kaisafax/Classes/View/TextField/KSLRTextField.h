//
//  KSLRTextField.h
//  kaisafax
//
//  Created by semny on 16/9/22.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KSLRTextField : UITextField

/**
 *  @author semny
 *
 *  设置左边视图的上下左右偏移
 *
 *  @param rectInsets 偏移量
 */
- (void)setLeftViewRectInsets:(UIEdgeInsets)rectInsets;

/**
 *  @author semny
 *
 *  设置右边视图的上下左右偏移
 *
 *  @param rectInsets 偏移量
 */
- (void)setRightViewRectInsets:(UIEdgeInsets)rectInsets;

/**
 *  @author semny
 *
 *  设置左边视图左边偏移
 *
 *  @param rectInsetsLeft 左边偏移
 */
//- (void)setLeftViewRectInsetsLeft:(CGFloat)rectInsetsLeft;
//
///**
// *  @author semny
// *
// *  设置右边视图的右边偏移
// *
// *  @param rectInsetsRight 右边偏移
// */
//- (void)setRightViewRectInsetsRight:(CGFloat)rectInsetsRight;
//
///**
// *  @author semny
// *
// *  设置左边视图右边偏移
// *
// *  @param rectInsetsRight 右边偏移
// */
//- (void)setLeftViewRectInsetsRight:(CGFloat)rectInsetsRight;

@end
