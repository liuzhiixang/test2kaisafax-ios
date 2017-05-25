//
//  UIImage+Compress.h
//  jw
//
//  Created by SemnyQu on 14-6-22.
//
//

#import <UIKit/UIKit.h>



@interface UIImage (Compress)

////最小的压缩比例（0<maxCompression<=1）；此数据小于零的时候使用系统默认的压缩比例；
//@property (nonatomic, assign) float maxCompression;
//
///**
// *最大的允许压缩到的数据大小(优先判断数据长度，当达到指定的压缩比的时候，优先满足达到压缩的数据长度);此数据小于零的时候无限制数据长度；
// */
//@property (nonatomic, assign) float maxLength;

/**
 *  @brief 压缩图片资源
 *
 *  @return 得到压缩的图片资源
 */
- (NSData *)compress:(CGFloat)compression;
- (NSData *)compress:(CGFloat)compression maxSize:(CGSize)mSize;

#pragma mark -
#pragma mark ---------------UIImage scale-------------
- (UIImage *)scaleToSize:(CGSize)size;
- (UIImage *)fillSize:(CGSize) viewsize;
@end
