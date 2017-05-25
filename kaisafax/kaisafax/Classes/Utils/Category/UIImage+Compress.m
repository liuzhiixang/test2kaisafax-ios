//
//  UIImage+Compress.m
//  jw
//
//  Created by SemnyQu on 14-6-22.
//
//

#import "UIImage+Compress.h"

#define KImageMaxCompression 0.1f
#define KImageDataMaxLength  500000

@implementation UIImage (Compress)

- (NSData *)compress:(CGFloat)compression
{
    return [self compress:compression maxSize:CGSizeZero];
}

- (NSData *)compress:(CGFloat)compression maxSize:(CGSize)mSize
{
    //CGFloat compression = 0.9f;
    if (compression <= 0)
    {
        return nil;
    }
    
    //int maxFileSize = 0;
    NSData *imageData = nil;
    UIImage *scaledImage = nil;
    if (!CGSizeEqualToSize(mSize, CGSizeZero))
    {
        scaledImage = [self scaleToSize:mSize];
    }
    else
    {
        scaledImage = self;
    }
    imageData = UIImageJPEGRepresentation(scaledImage, 1.0f);
    NSLog(@"before compress uploadPic Size:%f KB compress:%f",(NSInteger)imageData.length/1024.0, compression);
    if(imageData.length <= KImageDataMaxLength)
    {
        NSLog(@"after compress uploadPic Size:%f KB",(NSInteger)imageData.length/1024.0);
        return imageData;
    }
    
    if ((imageData = UIImageJPEGRepresentation(scaledImage, compression)))
    {
        //maxFileSize = imageData.length;
        while (imageData.length > KImageDataMaxLength && compression > KImageMaxCompression)
        {
            compression -= 0.1f;
            imageData = UIImageJPEGRepresentation(self, compression);
        }
        
        NSLog(@"finally uploadPic Size:%f KB",(NSInteger)imageData.length/1024.0);
        return imageData;
    }
    
    return nil;
}

- (UIImage *)scaleToSize:(CGSize)size
{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    
    // 绘制改变大小的图片
    [self drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    // 返回新的改变大小后的图片
    return scaledImage;
}

- (UIImage *)fillSize:(CGSize) viewsize
{
    CGSize newSize = CGSizeMake(viewsize.width * 2, viewsize.height * 2);
    viewsize = newSize;
    CGSize size = self.size;
    
    CGFloat scalex = viewsize.width / size.width;
    CGFloat scaley = viewsize.height / size.height;
    CGFloat scale = MAX(scalex, scaley);
    
    UIGraphicsBeginImageContext(viewsize);
    
    CGFloat width = size.width * scale;
    CGFloat height = size.height * scale;
    
    float dwidth = ((viewsize.width - width) / 2.0f);
    float dheight = ((viewsize.height - height) / 2.0f);
    
    CGRect rect = CGRectMake(dwidth, dheight, size.width * scale, size.height * scale);
    [self drawInRect:rect];
    
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newimg;
}

@end
