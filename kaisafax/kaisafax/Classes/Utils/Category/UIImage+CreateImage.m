//
//  UIImage+CreateImage.m
//  kaisafax
//
//  Created by liuzhixiang on 2017/5/12.
//  Copyright © 2017年 kaisafax. All rights reserved.
//

#import "UIImage+CreateImage.h"

@implementation UIImage (CreateImage)
//京东E卡 创建 密码
+ ( UIImage *)createPassWordImage:( NSString *)str

{
    
    UIImage *image = [ UIImage imageNamed : @"ic_white_pwd_bg"];
    
    CGSize size= CGSizeMake (image. size . width , image. size . height ); // 画布大小
    
    UIGraphicsBeginImageContextWithOptions (size, NO , 0.0 );
    
    [image drawAtPoint : CGPointMake ( 0 , 0 )];
    
    // 获得一个位图图形上下文
    
    CGContextRef context= UIGraphicsGetCurrentContext ();
    
    CGContextDrawPath (context, kCGPathStroke );
    
    UIFont *font = [UIFont fontWithName:@"PingFangSC-Regular"size:14];
    
    if(font==nil){
        
        font = [UIFont fontWithName:@"Helvetica"size:14];
        
    }
    [str drawAtPoint : CGPointMake ( 0 , image. size . height * 0.1+2 ) withAttributes : @{ NSFontAttributeName :font , NSForegroundColorAttributeName :UIColorFromHex(0x4c4c4e) } ];
    
    UIImage *newImage= UIGraphicsGetImageFromCurrentImageContext ();
    
    UIGraphicsEndImageContext ();
    
    return newImage;
    
}

@end
