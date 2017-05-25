//
//  NSString+AttributeString.h
//  kaisafax
//
//  Created by BeiYu on 2016/12/9.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (AttributeString)
+(NSAttributedString *)getAttributedStringWithString:(NSString *)string lineSpace:(CGFloat)lineSpace;

@end
