//
//  SQScreenUtil.h
//  kaisafax
//
//  Created by Semny on 14/12/17.
//  Copyright (c) 2014年 kaisafax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SQScreenUtil : NSObject

/**
 *  获取屏幕像素
 *
 *  @return 屏幕像素
 */
+(float)getScreenPixel;

/**
 *  获取屏幕尺寸
 *
 *  @return 屏幕尺寸
 */
+(CGSize)getScreenSize;
@end
