//
//  SQImageUtil.m
//  semny
//
//  Created by SemnyQu on 14-7-1.
//
//

#import "SQImageUtil.h"
#import "UIImage+Compress.h"

#define kUploadImageSize CGSizeMake(640.0f,640.0f)

//提交的图片压缩比例
#define kUploadImageStartCompression 0.6f

@implementation SQImageUtil

+ (NSData *)compress:(UIImage *)image maxSize:(CGSize)viewsize compression:(float)cmp
{
    if (!image)
    {
        return nil;
    }
    
    /**
     *  @brief 判断是否压缩比例小于0
     */
    if (cmp <= 0.0f)
    {
        cmp = 1;
    }
    
    UIImage *uploadImage = nil;
    
    float scale = image.size.width / image.size.height;
    CGSize imageSize = image.size;
    if(image.size.width > image.size.height && image.size.height > viewsize.height)
    {
        //宽>高，且高>640
        float newImageHeight = viewsize.width;
        float newImageWidth = newImageHeight * scale;
        CGSize newImageSize = CGSizeMake(newImageWidth, newImageHeight);
        uploadImage = [image scaleToSize:newImageSize];
    }
    else if (image.size.height > image.size.width && image.size.width > viewsize.width)
    {
        //高>宽，且宽>640
        float newImageWidth = viewsize.width;
        float newImageHeight = newImageWidth / scale;
        CGSize newImageSize = CGSizeMake(newImageWidth, newImageHeight);
        uploadImage = [image scaleToSize:newImageSize];
    }
    else
    {
        uploadImage = [image scaleToSize:imageSize];//image;
    }
    
    //像素压缩百分比
    NSData *imgData = [uploadImage compress:cmp];
    return imgData;
}

+ (NSData *)uploadCompress:(UIImage *)img
{
    return [SQImageUtil compress:img maxSize:kUploadImageSize compression:kUploadImageStartCompression];
}

@end
