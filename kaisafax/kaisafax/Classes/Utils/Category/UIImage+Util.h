
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
typedef enum SQImageType
{
    SQImageTypeUnknown,
    SQImageTypeJPEG,
    SQImageTypePNG,
    SQImageTypeGIF,
    SQImageTypeTIFF,
    SQImageTypeWEBP
}SQImageType;

@interface UIImage (Util)


+ (UIImage *)imageFromColor:(UIColor *)color withFrame:(CGRect)frame;

// 缩放图片
- (UIImage *)rescaleImageToSize:(CGSize)size;

// 
- (UIImage *)cropImageToRect:(CGRect)cropRect;

//
- (CGSize)calculateNewSizeForCroppingBox:(CGSize)croppingBox;

//
- (UIImage *)cropCenterAndScaleImageToSize:(CGSize)cropSize;

//给图片增加边框
- (UIImage*)imageWithBorderFromImage:(CGFloat)borderWidth
                                   R:(CGFloat)R
                                   G:(CGFloat)G
                                   B:(CGFloat)B
                                   A:(CGFloat)A;

//- (UIImage *)accelerateBlurWithImage;

+ (UIImage *)fullResolutionImageFromALAsset:(ALAsset *)asset;

#pragma mark -
- (UIImage *)fillSize:(CGSize) viewsize;

+ (SQImageType)imageTypeFromData:(NSData *)data;

@end
