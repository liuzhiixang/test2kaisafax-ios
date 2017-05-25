//
//  SQScreenUtil.m
//  kaisafax
//
//  Created by Semny on 14/12/17.
//  Copyright (c) 2014年 kaisafax. All rights reserved.
//

#import "SQScreenUtil.h"

@implementation SQScreenUtil

+(float)getScreenPixel
{
    CGFloat screenPixel = [UIScreen mainScreen].currentMode.pixelAspectRatio;
    return screenPixel;
}

+(CGSize)getScreenSize
{
    CGSize screenSize = [UIScreen mainScreen].currentMode.size;
    return screenSize;
}

@end
