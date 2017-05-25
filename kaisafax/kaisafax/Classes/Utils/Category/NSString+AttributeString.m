//
//  NSString+AttributeString.m
//  kaisafax
//
//  Created by BeiYu on 2016/12/9.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "NSString+AttributeString.h"

@implementation NSString (AttributeString)
+(NSAttributedString *)getAttributedStringWithString:(NSString *)string lineSpace:(CGFloat)lineSpace {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpace; // 调整行间距
    NSRange range = NSMakeRange(0, [string length]);
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
    return attributedString;
}
@end
