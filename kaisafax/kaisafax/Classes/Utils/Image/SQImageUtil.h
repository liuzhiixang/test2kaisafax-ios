//
//  SQImageUtil.h
//  semny
//
//  Created by SemnyQu on 14-7-1.
//
//

#import <Foundation/Foundation.h>

@interface SQImageUtil : NSObject

/**
 *  @brief 压缩图片资源
 *
 *  @param image    原始图片
 *  @param viewsize 最大的图片尺寸
 *  @param cmp      压缩比例
 *
 *  @return 压缩后的图片data数据对象
 */
+ (NSData *)compress:(UIImage *)image maxSize:(CGSize)viewsize compression:(float)cmp;

/**
 *  @brief 压缩上传的图片
 *
 *  @param img 原始图片
 *
 *  @return 压缩后的图片data数据对象
 */
+ (NSData *)uploadCompress:(UIImage *)img;

@end
