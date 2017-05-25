//
//  KSYYLabel.m
//  kaisafax
//
//  Created by philipyu on 16/9/10.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import "KSYYLabel.h"
#import "NSString+AttributeString.h"

@implementation KSYYLabel

//#pragma mark - 创建联系客服的富文本并添加点击事件
-(void)customerServiceRichText:(NSString *)custStr
{
    // 1. 创建一个属性文本
//    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:custStr];
    
    NSMutableAttributedString *text = (NSMutableAttributedString*)[NSString getAttributedStringWithString:custStr lineSpace:5.0];
    
    //2.要着重显示的字符范围
    NSRange rang = [custStr rangeOfString:KCustomerServicePhone];
    
    // 2. 为文本设置属性
    //灰色文字
    NSInteger length1 = text.length-rang.length;
    NSDictionary *text1Dict = @{NSForegroundColorAttributeName:UIColorFromHex(0xa0a0a0), NSFontAttributeName:SYSFONT(14.0f)};
    NSRange range1 = NSMakeRange(0, length1);
    [text addAttributes:text1Dict range:range1];
    
    //橙色文字
    NSInteger length2 = rang.length;
    UIColor *orangeColor = NUI_HELPER.appOrangeColor;
    NSDictionary *text2Dict = @{NSForegroundColorAttributeName:orangeColor, NSFontAttributeName:SYSFONT(14.0f)};
    NSRange range2 = NSMakeRange(length1, length2);
    [text addAttributes:text2Dict range:range2];
    
    
    YYTextHighlight *highlight = [[YYTextHighlight alloc] init];
    [highlight setColor:[UIColor whiteColor]];
    highlight.tapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect)
    {
        //调打电话
       DEBUGG(@"tap event happen");
        NSString *telephone = KCustomerServicePhone;
        NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",telephone];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        
    };
    [text yy_setTextHighlight:highlight range:range2];
    
    // 3.赋值到yylabel
    
    self.attributedText = text ;
    self.textAlignment = NSTextAlignmentCenter;
    self.userInteractionEnabled = YES;
}


@end
