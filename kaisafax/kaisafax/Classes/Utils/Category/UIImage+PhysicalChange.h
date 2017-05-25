//
//  UIImage+PhysicalChange.h
//  OCR
//
//  Created by ren6 on 2/14/13.
//  Copyright (c) 2013 ren6. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage (PhysicalChange)
- (UIImage *)imageAtRect:(CGRect)rect;
- (UIImage *)imageByScalingProportionallyToMinimumSize:(CGSize)targetSize;
- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize;
- (UIImage *)imageByScalingToSize:(CGSize)targetSize;
- (UIImage *)imageRotatedByRadians:(CGFloat)radians;
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;

/**
 *  @brief  磨砂玻璃效果处理
 *
 *  @return 处理后的UIImage
 */
- (UIImage *)accelerateBlur:(CGFloat)blur;

@end;